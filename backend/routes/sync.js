const router = require('express').Router();
const db = require('../db');

function verificarSyncKey(req, res, next) {
  const key = req.headers['x-sync-key'];
  if (!key || key !== (process.env.SYNC_KEY || 'sync-sportline-2026')) {
    return res.status(401).json({ error: 'Clave de sincronización inválida.' });
  }
  next();
}

async function crearObtenerTienda(tienda_codigo, nombre, pais) {
  const codigo = tienda_codigo.toString().trim();
  const emailAuto = `${codigo.toLowerCase()}@sportline.com`;

  await db.query(
    `INSERT INTO tiendas (codigo, nombre, region, email, password_hash, activa, total_empleados)
     VALUES ($1, $2, $3, $4, 'sport123', true, 0)
     ON CONFLICT (codigo) DO NOTHING`,
    [codigo, nombre.toString().trim(), (pais || 'General').toString().trim(), emailAuto]
  );

  return db.one('SELECT id, nombre, total_empleados FROM tiendas WHERE codigo = $1', [codigo]);
}

/**
 * POST /api/sync/registrar-tienda
 * Crea la tienda si no existe, sin crear resultados ni fichas.
 */
router.post('/registrar-tienda', verificarSyncKey, async (req, res) => {
  const { tienda_codigo, nombre, pais } = req.body;
  if (!tienda_codigo || !nombre) {
    return res.status(400).json({ error: 'Faltan campos: tienda_codigo, nombre.' });
  }
  try {
    const existente = await db.one(
      'SELECT id, nombre FROM tiendas WHERE codigo = $1',
      [tienda_codigo.toString().trim()]
    );
    if (existente) return res.json({ ok: true, creada: false, tienda: existente.nombre });

    await crearObtenerTienda(tienda_codigo, nombre, pais);
    res.json({ ok: true, creada: true, tienda: nombre.toString().trim() });
  } catch (err) {
    console.error('[Registrar Tienda]', err.message);
    res.status(500).json({ error: err.message });
  }
});

/**
 * POST /api/sync/resultados
 * Body: { tienda_codigo, semana, porcentaje, nombre, pais, total_empleados? }
 */
router.post('/resultados', verificarSyncKey, async (req, res) => {
  const { tienda_codigo, semana: semanaNum, porcentaje, total_empleados, nombre, pais } = req.body;

  if (!tienda_codigo || semanaNum == null || porcentaje == null) {
    return res.status(400).json({ error: 'Faltan campos: tienda_codigo, semana, porcentaje.' });
  }

  try {
    let tienda = await db.one(
      'SELECT id, nombre, total_empleados FROM tiendas WHERE codigo = $1',
      [tienda_codigo.toString().trim()]
    );

    if (!tienda) {
      if (!nombre) return res.status(404).json({ error: `Tienda "${tienda_codigo}" no encontrada. Incluye "nombre" en el payload para crearla.` });
      tienda = await crearObtenerTienda(tienda_codigo, nombre, pais);
    }

    const nuevoTotal = parseInt(total_empleados);
    if (!isNaN(nuevoTotal) && nuevoTotal > 0 && nuevoTotal !== tienda.total_empleados) {
      await db.query('UPDATE tiendas SET total_empleados = $1 WHERE id = $2', [nuevoTotal, tienda.id]);
    }

    const semana = await db.one('SELECT id, numero FROM semanas WHERE numero = $1', [parseInt(semanaNum)]);
    if (!semana) return res.status(404).json({ error: `Semana ${semanaNum} no encontrada.` });

    const pct = parseFloat(porcentaje) || 0;

    await db.query(
      `INSERT INTO resultados_tienda (tienda_id, semana_id, porcentaje_cumplido, cumplio_meta, updated_at)
       VALUES ($1, $2, $3, $4, NOW())
       ON CONFLICT (tienda_id, semana_id) DO UPDATE SET
         porcentaje_cumplido = EXCLUDED.porcentaje_cumplido,
         cumplio_meta = EXCLUDED.cumplio_meta,
         updated_at = NOW()`,
      [tienda.id, semana.id, pct, pct >= 100]
    );

    let desbloqueadas = 0;
    if (pct >= 100) {
      const { rows } = await db.query(
        `UPDATE fichas_tienda SET desbloqueado = true, fecha_desbloqueo = NOW()
         WHERE tienda_id = $1 AND semana_id = $2 AND desbloqueado = false
         RETURNING id`,
        [tienda.id, semana.id]
      );
      desbloqueadas = rows.length;
    }

    res.json({
      ok: true,
      tienda:           tienda.nombre,
      semana:           semana.numero,
      porcentaje:       pct,
      fichas_desbloqueadas: desbloqueadas,
      total_empleados:  !isNaN(nuevoTotal) && nuevoTotal > 0 ? nuevoTotal : tienda.total_empleados,
    });

  } catch (err) {
    console.error('[Sync Resultados]', err.message);
    res.status(500).json({ error: 'Error en sincronización: ' + err.message });
  }
});

module.exports = router;
