const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function verificarAdmin(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token faltante.' });
  try {
    const u = jwt.verify(token, process.env.JWT_SECRET);
    if (u.rol !== 'admin') return res.status(403).json({ error: 'Solo para administradores.' });
    req.usuario = u;
    next();
  } catch {
    res.status(401).json({ error: 'Sesión inválida.' });
  }
}

// GET /api/semanas — lista todas las semanas con su estado
router.get('/', verificarAdmin, async (req, res) => {
  const { data, error } = await supabase
    .from('semanas').select('id, numero, nombre, activa').order('numero');
  if (error) return res.status(500).json({ error: error.message });
  res.json({ semanas: data || [] });
});

// PUT /api/semanas/:numero/activar — activa esa semana y desactiva las demás
router.put('/:numero/activar', verificarAdmin, async (req, res) => {
  const numero = parseInt(req.params.numero);
  if (isNaN(numero) || numero < 1 || numero > 6) {
    return res.status(400).json({ error: 'Número de semana inválido (1-6).' });
  }
  try {
    await supabase.from('semanas').update({ activa: false }).neq('numero', numero);
    const { error } = await supabase.from('semanas').update({ activa: true }).eq('numero', numero);
    if (error) throw error;
    res.json({ ok: true, semana_activa: numero });
  } catch (err) {
    res.status(500).json({ error: 'Error al activar semana: ' + err.message });
  }
});

// GET /api/semanas/:numero/fotos — tiendas que desbloquearon fichas Y subieron foto
router.get('/:numero/fotos', verificarAdmin, async (req, res) => {
  const numero = parseInt(req.params.numero);
  if (isNaN(numero) || numero < 1 || numero > 6)
    return res.status(400).json({ error: 'Número de semana inválido (1-6).' });

  try {
    const { data: semana } = await supabase
      .from('semanas').select('id, numero').eq('numero', numero).maybeSingle();
    if (!semana) return res.status(404).json({ error: 'Semana no encontrada.' });

    const { data: fichas, error: fErr } = await supabase
      .from('fichas_tienda')
      .select('tienda_id, numero_ficha, foto_url')
      .eq('semana_id', semana.id)
      .eq('desbloqueado', true)
      .not('foto_url', 'is', null);
    if (fErr) throw fErr;

    if (!fichas || fichas.length === 0)
      return res.json({ fotos: [], total_tiendas: 0, semana: numero });

    const tiendaFotos = {};
    for (const f of fichas) {
      if (!tiendaFotos[f.tienda_id]) tiendaFotos[f.tienda_id] = [];
      tiendaFotos[f.tienda_id].push({ numero_ficha: f.numero_ficha, foto_url: f.foto_url });
    }

    const tiendaIds = Object.keys(tiendaFotos);
    const tiendas = [];
    for (let i = 0; i < tiendaIds.length; i += 50) {
      const { data: t } = await supabase
        .from('tiendas').select('id, codigo, nombre, region')
        .in('id', tiendaIds.slice(i, i + 50));
      if (t) tiendas.push(...t);
    }

    const resultado = tiendas
      .map(t => ({
        tienda_id: t.id,
        codigo: t.codigo,
        nombre: t.nombre,
        region: t.region || 'General',
        fotos: tiendaFotos[t.id] || [],
      }))
      .sort((a, b) => b.fotos.length - a.fotos.length);

    res.json({ fotos: resultado, total_tiendas: resultado.length, semana: numero });
  } catch (err) {
    console.error('[Semana Fotos]', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
