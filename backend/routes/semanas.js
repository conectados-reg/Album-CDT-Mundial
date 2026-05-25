const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function verificarAdmin(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token faltante.' });
  try {
    const u = jwt.verify(token, process.env.JWT_SECRET || 'secretomocal123');
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

module.exports = router;
