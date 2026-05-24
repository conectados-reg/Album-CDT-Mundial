const router   = require('express').Router();
const jwt      = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function verificarToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Acceso no autorizado.' });
  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Sesión expirada o inválida.' });
  }
}

// Registro de tiendas
router.post('/registrar', async (req, res) => {
  const { email, password, nombre, region, city } = req.body;
  if (!email || !password || !nombre) return res.status(400).json({ error: 'Faltan campos.' });

  try {
    const { data: existe } = await supabase.from('tiendas').select('id').eq('email', email.trim().toLowerCase()).maybeSingle();
    if (existe) return res.status(400).json({ error: 'Este correo ya existe.' });

    const codigoGenerado = "SL-" + email.split('@')[0].toUpperCase();

    const { data: nuevaTienda, error } = await supabase.from('tiendas').insert([{
      email: email.trim().toLowerCase(),
      codigo: codigoGenerado,
      password_hash: password, 
      nombre: nombre.trim(),
      region: region || 'General',
      ciudad: city || 'General',
      activa: true,
      total_empleados: 0
    }]).select().single();

    if (error) throw error;
    res.json({ success: true, tienda: nuevaTienda });
  } catch (error) {
    res.status(500).json({ error: 'Error al registrar.' });
  }
});

// Cargar tiendas en el panel de Administración (Petición raíz del archivo stores.js)
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Permiso denegado.' });

  try {
    const { data: resumen, error } = await supabase
      .from('tiendas')
      .select('id, codigo, email, password_hash, nombre, region, ciudad, total_empleados, activa')
      .order('nombre');

    if (error) throw error;

    const tiendasProcesadas = (resumen || []).map(t => ({
      id: t.id, 
      codigo: t.codigo, 
      email: t.email || 'Sin correo', 
      clave: t.password_hash, 
      nombre: t.nombre, 
      region: t.region, 
      ciudad: t.ciudad,
      total_empleados: t.total_empleados, 
      desbloqueados: 0, 
      activa: t.activa
    }));

    res.json({ tiendas: tiendasProcesadas });
  } catch (error) {
    res.status(500).json({ error: 'Error al leer tiendas.' });
  }
});

module.exports = router;
