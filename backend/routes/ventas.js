const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function verificarToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token faltante.' });
  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET || 'secretomocal123');
    next();
  } catch {
    res.status(401).json({ error: 'Sesión inválida.' });
  }
}

// GET /api/ventas — resultados de la semana activa para la tienda
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  try {
    const { data: semana } = await supabase
      .from('semanas').select('id, numero, nombre').eq('activa', true).single();
    if (!semana) return res.json({ resultados: [], semana: null });

    const { data: empleados } = await supabase
      .from('empleados')
      .select('id, nombre, cargo')
      .eq('tienda_id', req.usuario.id)
      .eq('activo', true)
      .order('nombre');

    const empIds = (empleados || []).map(e => e.id);
    const { data: resultados } = empIds.length
      ? await supabase
          .from('resultados_ventas')
          .select('empleado_id, porcentaje_cumplido, cumplio_meta')
          .eq('semana_id', semana.id)
          .in('empleado_id', empIds)
      : { data: [] };

    const mapa = {};
    for (const r of (resultados || [])) mapa[r.empleado_id] = r;

    const lista = (empleados || []).map(e => ({
      id: e.id,
      nombre: e.nombre,
      cargo: e.cargo || 'Asesor de Ventas',
      porcentaje: mapa[e.id]?.porcentaje_cumplido ?? null,
      cumplio_meta: mapa[e.id]?.cumplio_meta || false
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
    const { data: semana } = await supabase
      .from('semanas').select('id, numero').eq('activa', true).single();
    if (!semana) return res.status(400).json({ error: 'No hay semana activa.' });

    const empIds = resultados.map(r => r.empleado_id);
    const { data: emps } = await supabase
      .from('empleados').select('id')
      .eq('tienda_id', req.usuario.id).eq('activo', true).in('id', empIds);
    const validSet = new Set((emps || []).map(e => e.id));

    const filas = resultados
      .filter(r => validSet.has(r.empleado_id))
      .map(r => ({
        empleado_id: r.empleado_id,
        semana_id: semana.id,
        porcentaje_cumplido: Math.max(0, parseFloat(r.porcentaje) || 0),
        cumplio_meta: (parseFloat(r.porcentaje) || 0) >= 100
      }));

    if (!filas.length) return res.status(400).json({ error: 'Sin empleados válidos.' });

    const { error } = await supabase
      .from('resultados_ventas')
      .upsert(filas, { onConflict: 'empleado_id,semana_id' });
    if (error) throw error;

    const calificados = filas.filter(f => f.cumplio_meta);
    if (calificados.length) {
      await supabase.from('espacios_album').upsert(
        calificados.map(f => ({
          empleado_id: f.empleado_id,
          semana_id: semana.id,
          desbloqueado: true,
          fecha_desbloqueo: new Date().toISOString()
        })),
        { onConflict: 'empleado_id,semana_id' }
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
    const { data: semana } = await supabase
      .from('semanas').select('id, numero, nombre, fecha_inicio, fecha_fin')
      .eq('numero', parseInt(req.params.numero)).single();
    if (!semana) return res.status(404).json({ error: 'Semana no encontrada.' });

    const { data: resultados, error: rErr } = await supabase
      .from('resultados_ventas')
      .select('empleado_id, porcentaje_cumplido, cumplio_meta')
      .eq('semana_id', semana.id);
    if (rErr) throw rErr;
    if (!resultados?.length) return res.json({ semana, tiendas: [] });

    const empIds = resultados.map(r => r.empleado_id);
    const { data: empleados, error: eErr } = await supabase
      .from('empleados').select('id, nombre, cargo, tienda_id').in('id', empIds);
    if (eErr) throw eErr;

    const tiendaIds = [...new Set((empleados || []).map(e => e.tienda_id))];
    const { data: tiendas, error: tErr } = await supabase
      .from('tiendas').select('id, nombre, region, ciudad').in('id', tiendaIds);
    if (tErr) throw tErr;

    const tiendaMap = {};
    for (const t of (tiendas || [])) tiendaMap[t.id] = t;
    const empMap = {};
    for (const e of (empleados || [])) empMap[e.id] = e;

    const porTienda = {};
    for (const r of resultados) {
      const emp = empMap[r.empleado_id];
      if (!emp) continue;
      const t = tiendaMap[emp.tienda_id];
      if (!t) continue;
      if (!porTienda[t.id]) {
        porTienda[t.id] = { tienda_id: t.id, nombre: t.nombre, region: t.region, ciudad: t.ciudad, total: 0, cumplieron: 0, empleados: [] };
      }
      porTienda[t.id].total++;
      if (r.cumplio_meta) porTienda[t.id].cumplieron++;
      porTienda[t.id].empleados.push({ nombre: emp.nombre, cargo: emp.cargo, porcentaje: r.porcentaje_cumplido, cumplio_meta: r.cumplio_meta });
    }

    res.json({ semana, tiendas: Object.values(porTienda) });
  } catch (err) {
    console.error('[Ventas Admin]', err.message);
    res.status(500).json({ error: 'Error al obtener reporte: ' + err.message });
  }
});

module.exports = router;
