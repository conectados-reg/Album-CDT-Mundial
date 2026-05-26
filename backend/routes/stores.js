const router = require('express').Router();
const { verificarToken } = require('./auth');
const db = require('../db');

// GET /api/tiendas/lista — público, solo nombre/email/region para el dropdown del login
router.get('/lista', async (req, res) => {
  try {
    const tiendas = await db.all(
      `SELECT email, nombre, region, codigo FROM tiendas
       WHERE activa = true ORDER BY region NULLS LAST, nombre`
    );
    res.json({ tiendas });
  } catch (err) {
    console.error('[Tiendas Lista]', err.message);
    res.status(500).json({ error: 'Error al cargar tiendas.' });
  }
});

// GET /api/tiendas/ — admin: lista completa con datos sensibles
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') {
    return res.status(403).json({ error: 'No eres administrador.' });
  }

  try {
    const tiendas = await db.all(
      `SELECT id, codigo, email, password_hash, nombre, region, ciudad, total_empleados, activa
       FROM tiendas ORDER BY region NULLS LAST, nombre`
    );

    const tiendasFormateadas = tiendas.map(t => ({
      id:              t.id,
      codigo:          t.codigo,
      email:           t.email || 'Sin correo',
      clave:           t.password_hash,
      nombre:          t.nombre,
      region:          t.region || 'General',
      ciudad:          t.ciudad || 'General',
      total_empleados: t.total_empleados || 0,
      activa:          t.activa,
    }));

    res.json({ tiendas: tiendasFormateadas });
  } catch (err) {
    console.error('[Tiendas Admin]', err.message);
    res.status(500).json({ error: 'Error en la base de datos.' });
  }
});

module.exports = router;
