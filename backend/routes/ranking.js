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

// GET /api/ranking/nacional
// Devuelve el ranking de todas las tiendas activas del mismo país (region)
// que la tienda autenticada, ordenadas por cumplimiento acumulado promedio.
router.get('/nacional', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda')
    return res.status(403).json({ error: 'Solo para sucursales.' });

  try {
    const { data: tiendaPropia, error: tErr } = await supabase
      .from('tiendas')
      .select('id, nombre, region')
      .eq('id', req.usuario.id)
      .maybeSingle();

    if (tErr || !tiendaPropia)
      return res.status(404).json({ error: 'Tienda no encontrada.' });

    if (!tiendaPropia.region)
      return res.json({ ranking: [], region: null });

    const { data: tiendas, error: tdErr } = await supabase
      .from('tiendas')
      .select('id, nombre, region, codigo')
      .eq('region', tiendaPropia.region)
      .eq('activa', true)
      .order('nombre');

    if (tdErr) throw tdErr;
    if (!tiendas || tiendas.length === 0)
      return res.json({ ranking: [], region: tiendaPropia.region });

    const tiendaIds = tiendas.map(t => t.id);

    const { data: resultados, error: rErr } = await supabase
      .from('resultados_tienda')
      .select('tienda_id, porcentaje_cumplido')
      .in('tienda_id', tiendaIds);

    if (rErr) throw rErr;

    // Promedio acumulado por tienda
    const acumulado = {};
    for (const r of (resultados || [])) {
      if (!acumulado[r.tienda_id]) acumulado[r.tienda_id] = { suma: 0, semanas: 0 };
      acumulado[r.tienda_id].suma += r.porcentaje_cumplido;
      acumulado[r.tienda_id].semanas++;
    }

    const ranking = tiendas
      .map(t => {
        const ac = acumulado[t.id];
        return {
          id: t.id,
          nombre: t.nombre,
          region: t.region,
          codigo: t.codigo,
          cumplimiento_acumulado: ac ? Math.round(ac.suma / ac.semanas) : 0,
          semanas_registradas: ac ? ac.semanas : 0,
          es_mi_tienda: t.id === req.usuario.id,
        };
      })
      .sort((a, b) => b.cumplimiento_acumulado - a.cumplimiento_acumulado)
      .map((t, i) => ({ ...t, posicion: i + 1 }));

    res.json({ ranking, region: tiendaPropia.region });

  } catch (err) {
    console.error('[Ranking Nacional]', err.message);
    res.status(500).json({ error: 'Error al cargar el ranking.' });
  }
});

module.exports = router;
