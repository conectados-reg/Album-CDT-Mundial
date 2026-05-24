const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

// Middleware para validar el token JWT del administrador
function verificarToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Acceso denegado. Token faltante.' });
  
  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (error) {
    res.status(401).json({ error: 'Sesión inválida o expirada.' });
  }
}

// Obtener todas las tiendas para el Panel de Administración
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') {
    return res.status(403).json({ error: 'Permisos insuficientes para ver esta sección.' });
  }

  try {
    const { data: tiendas, error } = await supabase
      .from('tiendas')
      .select('id, codigo, email, password_hash, nombre, region, ciudad, total_empleados, activa')
      .order('nombre');

    if (error) throw error;

    // Mapeo limpio para entregar los datos idénticos a como los espera el admin.html
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
    res.status(500).json({ error: 'Error al consultar la base de datos de tiendas.' });
  }
});

module.exports = router;
