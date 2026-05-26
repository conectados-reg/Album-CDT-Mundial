const router = require('express').Router();
const { verificarToken } = require('./auth');
const db = require('../db');

function verificarAdmin(req, res, next) {
  verificarToken(req, res, () => {
    if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Solo para administradores.' });
    next();
  });
}

// GET /api/semanas — lista todas las semanas con su estado
router.get('/', verificarAdmin, async (req, res) => {
  try {
    const semanas = await db.all('SELECT id, numero, nombre, activa FROM semanas ORDER BY numero');
    res.json({ semanas });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/semanas/:numero/activar — activa esa semana y desactiva las demás
router.put('/:numero/activar', verificarAdmin, async (req, res) => {
  const numero = parseInt(req.params.numero);
  if (isNaN(numero) || numero < 1 || numero > 6) {
    return res.status(400).json({ error: 'Número de semana inválido (1-6).' });
  }
  try {
    await db.query('UPDATE semanas SET activa = false WHERE numero != $1', [numero]);
    await db.query('UPDATE semanas SET activa = true  WHERE numero = $1',  [numero]);
    res.json({ ok: true, semana_activa: numero });
  } catch (err) {
    res.status(500).json({ error: 'Error al activar semana: ' + err.message });
  }
});

module.exports = router;
