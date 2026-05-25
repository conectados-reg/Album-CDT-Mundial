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
  } catch (error) {
    res.status(401).json({ error: 'Sesión inválida.' });
  }
}

// GET /api/tiendas/lista — público, solo nombre/email/region para el dropdown del login
router.get('/lista', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('tiendas')
      .select('email, nombre, region')
      .eq('activa', true)
      .order('region', { nullsFirst: false })
      .order('nombre');
    if (error) throw error;
    res.json({ tiendas: data || [] });
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
    const { data: tiendas, error } = await supabase
      .from('tiendas')
      .select('id, codigo, email, password_hash, nombre, region, ciudad, total_empleados, activa')
      .order('region', { nullsFirst: false })
      .order('nombre');

    if (error) throw error;

    const tiendasFormateadas = (tiendas || []).map(t => ({
      id: t.id,
      codigo: t.codigo,
      email: t.email || 'Sin correo',
      clave: t.password_hash,
      nombre: t.nombre,
      region: t.region || 'General',
      ciudad: t.ciudad || 'General',
      total_empleados: t.total_empleados || 0,
      activa: t.activa
    }));

    res.json({ tiendas: tiendasFormateadas });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error en la base de datos.' });
  }
});

module.exports = router;
