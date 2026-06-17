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
  const [{ data: resultados, error: rErr }, { data: fichasDesb, error: fErr }, { data: fichasTot, error: ftErr }] =
    await Promise.all([
      supabase.from('resultados_tienda').select('tienda_id, porcentaje_cumplido').in('tienda_id', tiendaIds),
      supabase.from('fichas_tienda').select('tienda_id').eq('desbloqueado', true).in('tienda_id', tiendaIds),
      supabase.from('fichas_tienda').select('tienda_id').in('tienda_id', tiendaIds),
    ]);
  if (rErr) throw rErr;
  if (fErr) throw fErr;
  if (ftErr) throw ftErr;

  const acumulado = {};
  for (const r of (resultados || [])) {
    if (!acumulado[r.tienda_id]) acumulado[r.tienda_id] = { suma: 0, semanas: 0 };
    acumulado[r.tienda_id].suma += r.porcentaje_cumplido;
    acumulado[r.tienda_id].semanas++;
  }

  const fichasDesbCount = {};
  for (const f of (fichasDesb || [])) fichasDesbCount[f.tienda_id] = (fichasDesbCount[f.tienda_id] || 0) + 1;

  const fichasTotCount = {};
  for (const f of (fichasTot || [])) fichasTotCount[f.tienda_id] = (fichasTotCount[f.tienda_id] || 0) + 1;

  return { acumulado, fichasDesbCount, fichasTotCount };
}

function calcCumplimiento(ac) {
  return ac ? Math.round(ac.suma / ac.semanas) : 0;
}

function rankSort(a, b) {
  if (b.cumplimiento_acumulado !== a.cumplimiento_acumulado)
    return b.cumplimiento_acumulado - a.cumplimiento_acumulado;
  return b.fichas_desbloqueadas - a.fichas_desbloqueadas;
}

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
      .select('id, nombre, region, codigo')
      .eq('region', tiendaPropia.region)
      .eq('activa', true)
      .order('nombre');

    if (tdErr) throw tdErr;
    if (!tiendas || tiendas.length === 0)
      return res.json({ ranking: [], region: tiendaPropia.region });

    const tiendaIds = tiendas.map(t => t.id);
    const { acumulado, fichasDesbCount } = await buildMaps(tiendaIds);

    const ranking = tiendas
      .map(t => ({
        id: t.id,
        nombre: t.nombre,
        region: t.region,
        codigo: t.codigo,
        cumplimiento_acumulado: calcCumplimiento(acumulado[t.id]),
        fichas_desbloqueadas: fichasDesbCount[t.id] || 0,
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
      .select('id, nombre, region, codigo')
      .eq('activa', true)
      .order('nombre');
    if (tErr) throw tErr;

    if (!tiendas || tiendas.length === 0)
      return res.json({ ranking: [], total: 0 });

    const tiendaIds = tiendas.map(t => t.id);
    const { acumulado, fichasDesbCount } = await buildMaps(tiendaIds);

    const ranking = tiendas
      .map(t => ({
        id: t.id,
        nombre: t.nombre,
        region: t.region,
        codigo: t.codigo,
        cumplimiento_acumulado: calcCumplimiento(acumulado[t.id]),
        fichas_desbloqueadas: fichasDesbCount[t.id] || 0,
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
      .select('id, nombre, region, codigo')
      .eq('activa', true);
    if (tErr) throw tErr;

    const tiendaInfo = todasTiendas.find(t => t.id === tiendaId);
    if (!tiendaInfo) return res.status(404).json({ error: 'Tienda no encontrada.' });

    const tiendaIds = todasTiendas.map(t => t.id);
    const { acumulado, fichasDesbCount, fichasTotCount } = await buildMaps(tiendaIds);

    const enrich = t => ({
      id: t.id,
      cumplimiento_acumulado: calcCumplimiento(acumulado[t.id]),
      fichas_desbloqueadas: fichasDesbCount[t.id] || 0,
    });

    const rankingMundial = todasTiendas.map(enrich).sort(rankSort);
    const posicionMundial = rankingMundial.findIndex(t => t.id === tiendaId) + 1;

    const mismaRegion = todasTiendas.filter(t => t.region === tiendaInfo.region);
    const rankingNacional = mismaRegion.map(enrich).sort(rankSort);
    const posicionNacional = rankingNacional.findIndex(t => t.id === tiendaId) + 1;

    // Fotos públicas de esta tienda (solo fichas desbloqueadas con foto)
    const { data: fichasFotos } = await supabase
      .from('fichas_tienda')
      .select('id, numero_ficha, semana_numero, semana_nombre, foto_url')
      .eq('tienda_id', tiendaId)
      .eq('desbloqueado', true)
      .not('foto_url', 'is', null)
      .order('semana_numero', { ascending: true })
      .order('numero_ficha', { ascending: true });

    res.json({
      id: tiendaInfo.id,
      nombre: tiendaInfo.nombre,
      region: tiendaInfo.region,
      codigo: tiendaInfo.codigo,
      cumplimiento_acumulado: calcCumplimiento(acumulado[tiendaId]),
      fichas_desbloqueadas: fichasDesbCount[tiendaId] || 0,
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
