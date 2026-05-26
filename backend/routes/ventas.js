const router = require('express').Router();
const { verificarToken } = require('./auth');
const db = require('../db');

// GET /api/ventas — resultados de la semana activa para la tienda
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  try {
    const semana = await db.one('SELECT id, numero, nombre FROM semanas WHERE activa = true LIMIT 1');
    if (!semana) return res.json({ resultados: [], semana: null });

    const empleados = await db.all(
      'SELECT id, nombre, cargo FROM empleados WHERE tienda_id = $1 AND activo = true ORDER BY nombre',
      [req.usuario.id]
    );

    const empIds = empleados.map(e => e.id);
    const resultados = empIds.length
      ? await db.all(
          'SELECT empleado_id, porcentaje_cumplido, cumplio_meta FROM resultados_ventas WHERE semana_id = $1 AND empleado_id = ANY($2)',
          [semana.id, empIds]
        )
      : [];

    const mapa = Object.fromEntries(resultados.map(r => [r.empleado_id, r]));

    const lista = empleados.map(e => ({
      id:          e.id,
      nombre:      e.nombre,
      cargo:       e.cargo || 'Asesor de Ventas',
      porcentaje:  mapa[e.id]?.porcentaje_cumplido ?? null,
      cumplio_meta: mapa[e.id]?.cumplio_meta || false,
    }));

    res.json({ resultados: lista, semana });
  } catch (err) {
    console.error('[Ventas GET]', err.message);
    res.status(500).json({ error: 'Error al obtener ventas.' });
  }
});

// POST /api/ventas — registrar resultados semanales y desbloquear espacios al 100%
router.post('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  const { resultados } = req.body;
  if (!Array.isArray(resultados) || !resultados.length) {
    return res.status(400).json({ error: 'Datos de ventas requeridos.' });
  }
  try {
    const semana = await db.one('SELECT id, numero FROM semanas WHERE activa = true LIMIT 1');
    if (!semana) return res.status(400).json({ error: 'No hay semana activa.' });

    const empIds  = resultados.map(r => r.empleado_id);
    const empsVal = await db.all(
      'SELECT id FROM empleados WHERE tienda_id = $1 AND activo = true AND id = ANY($2)',
      [req.usuario.id, empIds]
    );
    const validSet = new Set(empsVal.map(e => e.id));

    const filas = resultados
      .filter(r => validSet.has(r.empleado_id))
      .map(r => ({
        empleado_id:        r.empleado_id,
        semana_id:          semana.id,
        porcentaje_cumplido: Math.max(0, parseFloat(r.porcentaje) || 0),
        cumplio_meta:       (parseFloat(r.porcentaje) || 0) >= 100,
      }));

    if (!filas.length) return res.status(400).json({ error: 'Sin empleados válidos.' });

    // Batch upsert resultados_ventas
    const vals1  = db.buildValues(filas, 4);
    const pms1   = filas.flatMap(f => [f.empleado_id, f.semana_id, f.porcentaje_cumplido, f.cumplio_meta]);
    await db.query(
      `INSERT INTO resultados_ventas (empleado_id, semana_id, porcentaje_cumplido, cumplio_meta)
       VALUES ${vals1}
       ON CONFLICT (empleado_id, semana_id) DO UPDATE SET
         porcentaje_cumplido = EXCLUDED.porcentaje_cumplido,
         cumplio_meta = EXCLUDED.cumplio_meta`,
      pms1
    );

    const calificados = filas.filter(f => f.cumplio_meta);
    if (calificados.length) {
      const vals2 = db.buildValues(calificados, 2);
      const pms2  = calificados.flatMap(f => [f.empleado_id, f.semana_id]);
      await db.query(
        `INSERT INTO espacios_album (empleado_id, semana_id, desbloqueado, fecha_desbloqueo)
         VALUES ${vals2.replace(/\(([^)]+)\)/g, '($1, true, NOW())')}
         ON CONFLICT (empleado_id, semana_id) DO UPDATE SET
           desbloqueado = true, fecha_desbloqueo = NOW()`,
        pms2
      );
    }

    res.json({ ok: true, registrados: filas.length, desbloqueados: calificados.length });
  } catch (err) {
    console.error('[Ventas POST]', err.message);
    res.status(500).json({ error: 'Error al registrar ventas.' });
  }
});

// GET /api/ventas/admin/semana/:numero — admin ve rendimiento por tienda en una semana
router.get('/admin/semana/:numero', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Solo para admin.' });
  try {
    const semana = await db.one(
      'SELECT id, numero, nombre, fecha_inicio, fecha_fin FROM semanas WHERE numero = $1',
      [parseInt(req.params.numero)]
    );
    if (!semana) return res.status(404).json({ error: 'Semana no encontrada.' });

    const rows = await db.all(
      `SELECT rv.empleado_id, rv.porcentaje_cumplido, rv.cumplio_meta,
              e.nombre AS emp_nombre, e.cargo, e.tienda_id,
              t.nombre AS tienda_nombre, t.region, t.ciudad
       FROM resultados_ventas rv
       JOIN empleados e ON e.id = rv.empleado_id
       JOIN tiendas   t ON t.id = e.tienda_id
       WHERE rv.semana_id = $1`,
      [semana.id]
    );

    if (!rows.length) return res.json({ semana, tiendas: [] });

    const porTienda = {};
    for (const r of rows) {
      if (!porTienda[r.tienda_id]) {
        porTienda[r.tienda_id] = {
          tienda_id: r.tienda_id,
          nombre:    r.tienda_nombre,
          region:    r.region,
          ciudad:    r.ciudad,
          total:     0, cumplieron: 0, empleados: [],
        };
      }
      porTienda[r.tienda_id].total++;
      if (r.cumplio_meta) porTienda[r.tienda_id].cumplieron++;
      porTienda[r.tienda_id].empleados.push({
        nombre:      r.emp_nombre,
        cargo:       r.cargo,
        porcentaje:  r.porcentaje_cumplido,
        cumplio_meta: r.cumplio_meta,
      });
    }

    res.json({ semana, tiendas: Object.values(porTienda) });
  } catch (err) {
    console.error('[Ventas Admin]', err.message);
    res.status(500).json({ error: 'Error al obtener reporte: ' + err.message });
  }
});

module.exports = router;
