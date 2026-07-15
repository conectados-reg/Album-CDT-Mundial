const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function verificarToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token faltante.' });
  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Sesión inválida.' });
  }
}

// Helper: builds acumulado + fichas maps for an array of tiendaIds
async function buildMaps(tiendaIds) {
  const [
    { data: resultados, error: rErr },
    { data: fichasDesb, error: fErr },
    { data: fichasTot, error: ftErr },
    { data: fichasFotos, error: ffErr },
  ] = await Promise.all([
    supabase.from('resultados_tienda').select('tienda_id, semana_id, porcentaje_cumplido').in('tienda_id', tiendaIds),
    supabase.from('fichas_tienda').select('tienda_id').eq('desbloqueado', true).in('tienda_id', tiendaIds),
    supabase.from('fichas_tienda').select('tienda_id').in('tienda_id', tiendaIds),
    supabase.from('fichas_tienda').select('tienda_id').not('foto_url', 'is', null).in('tienda_id', tiendaIds),
  ]);
  if (rErr) throw rErr;
  if (fErr) throw fErr;
  if (ftErr) throw ftErr;
  if (ffErr) throw ffErr;

  // Deduplicar: si hay múltiples filas para la misma tienda+semana, queda el mayor valor
  const mejorPorSemana = {};
  for (const r of (resultados || [])) {
    const key = r.tienda_id + '|' + r.semana_id;
    if (mejorPorSemana[key] == null || r.porcentaje_cumplido > mejorPorSemana[key]) {
      mejorPorSemana[key] = r.porcentaje_cumplido;
    }
  }
  const acumulado = {};
  for (const [key, pct] of Object.entries(mejorPorSemana)) {
    const tienda_id = key.split('|')[0];
    if (!acumulado[tienda_id]) acumulado[tienda_id] = { suma: 0, semanas: 0 };
    acumulado[tienda_id].suma += pct;
    acumulado[tienda_id].semanas++;
  }

  const fichasDesbCount = {};
  for (const f of (fichasDesb || [])) fichasDesbCount[f.tienda_id] = (fichasDesbCount[f.tienda_id] || 0) + 1;

  const fichasTotCount = {};
  for (const f of (fichasTot || [])) fichasTotCount[f.tienda_id] = (fichasTotCount[f.tienda_id] || 0) + 1;

  const fotosCount = {};
  for (const f of (fichasFotos || [])) fotosCount[f.tienda_id] = (fotosCount[f.tienda_id] || 0) + 1;

  return { acumulado, fichasDesbCount, fichasTotCount, fotosCount };
}

function calcCumplimiento(ac) {
  return ac ? Math.round(ac.suma / ac.semanas) : 0;
}

function rankSort(a, b) {
  if (b.fotos_count !== a.fotos_count) return b.fotos_count - a.fotos_count;
  return b.fichas_desbloqueadas - a.fichas_desbloqueadas;
}

// GET /api/ranking/publico — sin auth, para la página pública compartible
router.get('/publico', async (req, res) => {
  try {
    const { data: tiendas, error: tErr } = await supabase
      .from('tiendas')
      .select('id, nombre, region, codigo, total_empleados, promedio_ranking')
      .eq('activa', true)
      .order('nombre');
    if (tErr) throw tErr;
    if (!tiendas || tiendas.length === 0)
      return res.json({ ranking: [], paises: [], total: 0 });

    // Resultados en lotes
    const todosResultados = [];
    let desde = 0;
    while (true) {
      const { data: lote, error: lErr } = await supabase
        .from('resultados_tienda')
        .select('tienda_id, semana_id, porcentaje_cumplido')
        .range(desde, desde + 999);
      if (lErr || !lote || lote.length === 0) break;
      todosResultados.push(...lote);
      if (lote.length < 1000) break;
      desde += 1000;
    }

    // Deduplicar: si hay múltiples filas para la misma tienda+semana, queda el mayor valor
    const mejorPorSemana = {};
    for (const r of todosResultados) {
      const key = r.tienda_id + '|' + r.semana_id;
      if (mejorPorSemana[key] == null || r.porcentaje_cumplido > mejorPorSemana[key]) {
        mejorPorSemana[key] = r.porcentaje_cumplido;
      }
    }
    const resPorTienda = {};
    for (const [key, pct] of Object.entries(mejorPorSemana)) {
      const tienda_id = key.split('|')[0];
      if (!resPorTienda[tienda_id]) resPorTienda[tienda_id] = [];
      resPorTienda[tienda_id].push(pct);
    }

    const ranking = tiendas
      .map(t => {
        const semanas = resPorTienda[t.id] || [];
        const suma = semanas.reduce((a, b) => a + (b || 0), 0);
        const pct_acumulado = t.promedio_ranking != null
          ? Math.round(t.promedio_ranking * 10) / 10
          : Math.round((suma / 6) * 10) / 10;
        return {
          codigo: t.codigo,
          nombre: t.nombre,
          region: t.region || 'General',
          total_empleados: t.total_empleados || 0,
          pct_acumulado,
          semanas_con_data: semanas.length,
        };
      })
      .filter(t => t.semanas_con_data > 0)
      .sort((a, b) => b.pct_acumulado - a.pct_acumulado);

    const paises = [...new Set(ranking.map(t => t.region))].sort();

    res.setHeader('Cache-Control', 'public, max-age=120');
    res.json({ ranking, paises, total: ranking.length, actualizado: new Date().toISOString() });
  } catch (err) {
    console.error('[Ranking Público]', err.message);
    res.status(500).json({ error: 'Error al cargar el ranking.' });
  }
});

// GET /api/ranking/nacional
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
      .select('id, nombre, region, codigo, promedio_ranking')
      .eq('region', tiendaPropia.region)
      .eq('activa', true)
      .order('nombre');

    if (tdErr) throw tdErr;
    if (!tiendas || tiendas.length === 0)
      return res.json({ ranking: [], region: tiendaPropia.region });

    const tiendaIds = tiendas.map(t => t.id);
    const { acumulado, fichasDesbCount, fotosCount } = await buildMaps(tiendaIds);

    const ranking = tiendas
      .map(t => ({
        id: t.id,
        nombre: t.nombre,
        region: t.region,
        codigo: t.codigo,
        cumplimiento_acumulado: t.promedio_ranking != null ? Math.round(t.promedio_ranking * 10) / 10 : calcCumplimiento(acumulado[t.id]),
        fichas_desbloqueadas: fichasDesbCount[t.id] || 0,
        fotos_count: fotosCount[t.id] || 0,
        semanas_registradas: acumulado[t.id]?.semanas || 0,
        es_mi_tienda: t.id === req.usuario.id,
      }))
      .sort(rankSort)
      .map((t, i) => ({ ...t, posicion: i + 1 }));

    res.json({ ranking, region: tiendaPropia.region });

  } catch (err) {
    console.error('[Ranking Nacional]', err.message);
    res.status(500).json({ error: 'Error al cargar el ranking.' });
  }
});

// GET /api/ranking/mundial
router.get('/mundial', verificarToken, async (req, res) => {
  try {
    const { data: tiendas, error: tErr } = await supabase
      .from('tiendas')
      .select('id, nombre, region, codigo, promedio_ranking')
      .eq('activa', true)
      .order('nombre');
    if (tErr) throw tErr;

    if (!tiendas || tiendas.length === 0)
      return res.json({ ranking: [], total: 0 });

    const tiendaIds = tiendas.map(t => t.id);
    const { acumulado, fichasDesbCount, fotosCount } = await buildMaps(tiendaIds);

    const ranking = tiendas
      .map(t => ({
        id: t.id,
        nombre: t.nombre,
        region: t.region,
        codigo: t.codigo,
        cumplimiento_acumulado: t.promedio_ranking != null ? Math.round(t.promedio_ranking * 10) / 10 : calcCumplimiento(acumulado[t.id]),
        fichas_desbloqueadas: fichasDesbCount[t.id] || 0,
        fotos_count: fotosCount[t.id] || 0,
        semanas_registradas: acumulado[t.id]?.semanas || 0,
        es_mi_tienda: t.id === req.usuario.id,
      }))
      .sort(rankSort)
      .map((t, i) => ({ ...t, posicion: i + 1 }));

    res.json({ ranking, total: ranking.length });

  } catch (err) {
    console.error('[Ranking Mundial]', err.message);
    res.status(500).json({ error: 'Error al cargar el ranking mundial.' });
  }
});

// GET /api/ranking/tienda/:id
router.get('/tienda/:id', verificarToken, async (req, res) => {
  try {
    const tiendaId = req.params.id;

    const { data: todasTiendas, error: tErr } = await supabase
      .from('tiendas')
      .select('id, nombre, region, codigo, promedio_ranking')
      .eq('activa', true);
    if (tErr) throw tErr;

    const tiendaInfo = todasTiendas.find(t => t.id === tiendaId);
    if (!tiendaInfo) return res.status(404).json({ error: 'Tienda no encontrada.' });

    const tiendaIds = todasTiendas.map(t => t.id);
    const { acumulado, fichasDesbCount, fichasTotCount, fotosCount } = await buildMaps(tiendaIds);

    const enrich = t => ({
      id: t.id,
      cumplimiento_acumulado: t.promedio_ranking != null ? Math.round(t.promedio_ranking * 10) / 10 : calcCumplimiento(acumulado[t.id]),
      fichas_desbloqueadas: fichasDesbCount[t.id] || 0,
      fotos_count: fotosCount[t.id] || 0,
    });

    const rankingMundial = todasTiendas.map(enrich).sort(rankSort);
    const posicionMundial = rankingMundial.findIndex(t => t.id === tiendaId) + 1;

    const mismaRegion = todasTiendas.filter(t => t.region === tiendaInfo.region);
    const rankingNacional = mismaRegion.map(enrich).sort(rankSort);
    const posicionNacional = rankingNacional.findIndex(t => t.id === tiendaId) + 1;

    // Fotos públicas de esta tienda (solo fichas desbloqueadas con foto)
    const { data: fichasFotos, error: fotErr } = await supabase
      .from('fichas_tienda')
      .select('id, numero_ficha, foto_url')
      .eq('tienda_id', tiendaId)
      .eq('desbloqueado', true)
      .not('foto_url', 'is', null)
      .order('numero_ficha', { ascending: true });
    if (fotErr) console.error('[Perfil Fotos]', fotErr.message);

    res.json({
      id: tiendaInfo.id,
      nombre: tiendaInfo.nombre,
      region: tiendaInfo.region,
      codigo: tiendaInfo.codigo,
      cumplimiento_acumulado: tiendaInfo.promedio_ranking != null ? Math.round(tiendaInfo.promedio_ranking * 10) / 10 : calcCumplimiento(acumulado[tiendaId]),
      fichas_desbloqueadas: fichasDesbCount[tiendaId] || 0,
      fotos_count: fotosCount[tiendaId] || 0,
      total_fichas: fichasTotCount[tiendaId] || 0,
      posicion_mundial: posicionMundial,
      posicion_nacional: posicionNacional,
      total_tiendas_mundial: todasTiendas.length,
      total_tiendas_nacional: mismaRegion.length,
      fotos: fichasFotos || [],
    });

  } catch (err) {
    console.error('[Perfil Tienda]', err.message);
    res.status(500).json({ error: 'Error al cargar el perfil de tienda.' });
  }
});

module.exports = router;
