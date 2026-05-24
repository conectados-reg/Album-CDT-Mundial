const router   = require('express').Router();
const jwt      = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

// Filtro protector para verificar el inicio de sesión
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

// 🆕 NUEVA RUTA: Permite a una tienda registrarse sola (Usa Correo y Texto Plano)
router.post('/registrar', async (req, res) => {
  const { email, password, nombre, region, ciudad } = req.body;

  if (!email || !password || !nombre) {
    return res.status(400).json({ error: 'Faltan campos obligatorios (Email, Contraseña o Nombre).' });
  }

  try {
    // Verificar si el correo ya existe
    const { data: existe } = await supabase.from('tiendas').select('id').eq('email', email.trim().toLowerCase()).substring();
    if (existe) return res.status(400).json({ error: 'Este correo ya está registrado.' });

    // Generar un código único basado en el nombre (ej: TDA-EMAIL) para no romper la estructura vieja
    const codigoGenerado = "TDA-" + email.split('@')[0].toUpperCase();

    // Insertar la nueva tienda en la base de datos (Empieza ACTIVA por defecto)
    const { data: nuevaTienda, error } = await supabase.from('tiendas').insert([{
      email: email.trim().toLowerCase(),
      codigo: codigoGenerado,
      password_hash: password, // Texto plano directo
      nombre: nombre.trim(),
      region: region || 'General',
      ciudad: ciudad || 'General',
      activa: true,
      total_empleados: 0
    }]).select().single();

    if (error) throw error;

    res.json({ success: true, mensaje: 'Tienda registrada con éxito.', tienda: nuevaTienda });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al registrar la tienda.' });
  }
});

// 🆕 NUEVA RUTA: Permite a la tienda actualizar su contraseña si se la sabe o si la recupera
router.post('/cambiar-password', async (req, res) => {
  const { email, nuevaPassword } = req.body;
  if (!email || !nuevaPassword) return res.status(400).json({ error: 'Campos incompletos.' });

  try {
    const { error } = await supabase
      .from('tiendas')
      .update({ password_hash: nuevaPassword })
      .eq('email', email.trim().toLowerCase());

    if (error) throw error;
    res.json({ success: true, mensaje: 'Contraseña actualizada correctamente.' });
  } catch (error) {
    res.status(500).json({ error: 'No se pudo actualizar la contraseña.' });
  }
});

// Carga los datos reales del álbum de una tienda
router.get('/:tiendaId/album', verificarToken, async (req, res) => {
  const { tiendaId } = req.params;

  if (req.usuario.rol === 'tienda' && req.usuario.tiendaId !== tiendaId) {
    return res.status(403).json({ error: 'Acceso denegado a esta sucursal.' });
  }

  const [{ data: tienda }, { data: empleados }, { data: semanas }] = await Promise.all([
    supabase.from('tiendas').select('*').eq('id', tiendaId).single(),
    supabase.from('empleados').select(`id, nombre, cargo, foto_url, semana_asignada, activo, espacios_album (desbloqueado, fecha_desbloqueo), resultados_ventas (porcentaje_cumplido, cumplio_meta)`).eq('tienda_id', tiendaId).eq('activo', true),
    supabase.from('semanas').select('*').order('numero')
  ]);

  res.json({ tienda, empleados, semanas });
});

// Panel de control general para el Administrador (Modificado para enviarte correos y claves)
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Permiso denegado.' });

  // 👁️ MODIFICADO: Ahora extrae 'email' y 'password_hash' para que los veas en tu panel
  const { data: resumen } = await supabase
    .from('tiendas')
    .select(`id, codigo, email, password_hash, nombre, region, ciudad, total_empleados, activa, empleados ( id, espacios_album (desbloqueado) )`)
    .order('nombre');

  const tiendasProcesadas = (resumen || []).map(t => {
    let estrellasDesbloqueadas = 0;
    t.empleados?.forEach(e => {
      if (e.espacios_album?.some(ea => ea.desbloqueado)) estrellasDesbloqueadas++;
    });
    return {
      id: t.id, 
      codigo: t.codigo, 
      email: t.email || 'Sin correo', 
      clave: t.password_hash, // 🔴 ¡Aquí viaja la contraseña en texto plano para tu tabla!
      nombre: t.nombre, 
      region: t.region, 
      ciudad: t.ciudad,
      total_empleados: t.total_empleados, 
      desbloqueados: estrellasDesbloqueadas,
      activa: t.activa
    };
  });

  res.json({ tiendas: tiendasProcesadas });
});

module.exports = router;
