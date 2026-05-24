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

// NUEVA RUTA: Permite a una tienda registrarse sola (Usa Correo y Texto Plano)
router.post('/registrar', async (req, res) => {
  const { email, password, nombre, region, ciudad } = req.body;

  if (!email || !password || !nombre) {
    return res.status(400).json({ error: 'Faltan campos obligatorios (Email, Contraseña o Nombre).' });
  }

  try {
    // 🔍 CORREGIDO: Se quitó el .substring() que rompía la consulta
    const { data: existe } = await supabase.from('tiendas').select('id').eq('email', email.trim().toLowerCase()).maybeSingle();
    if (existe) return res.status(400).json({ error: 'Este correo ya está registrado.' });

    // Generar un código único basado en el nombre
    const codigoGenerado = "TDA-" + email.split('@')[0].toUpperCase();

    // Insertar la nueva tienda en la base de datos
    const { data: nuevaTienda, error } = await supabase.from('tiendas').insert([{
      email: email.trim().toLowerCase(),
      codigo: codigoGenerado,
      password_hash: password, 
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

// NUEVA RUTA: Permite a la tienda actualizar su contraseña
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

  try {
    const [{ data: tienda }, { data: empleados }, { data: semanas }] = await Promise.all([
      supabase.from('tiendas').select('*').eq('id', tiendaId).single(),
      supabase.from('empleados').select(`id, nombre, cargo, foto_url, semana_asignada, activo, espacios_album (desbloqueado, fecha_desbloqueo), resultados_ventas (porcentaje_cumplido, cumplio_meta)`).eq('tienda_id', tiendaId).eq('activo', true),
      supabase.from('semanas').select('*').order('numero')
    ]);

    res.json({ tienda, empleados, semanas });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al cargar los datos del álbum.' });
  }
});

// Panel de control general para el Administrador (Optimizado para volumen masivo de 240 tiendas)
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Permiso denegado.' });

  try {
    // Extrae la lista limpia directamente en un segundo
    const { data: resumen, error } = await supabase
      .from('tiendas')
      .select('id, codigo, email, password_hash, nombre, region, ciudad, total_empleados, activa')
      .order('nombre');

    if (error) throw error;

    const tiendasProcesadas = (resumen || []).map(t => {
      return {
        id: t.id, 
        codigo: t.codigo, 
        email: t.email || 'Sin correo', 
        clave: t.password_hash, 
        nombre: t.nombre, 
        region: t.region, 
        ciudad: t.ciudad,
        total_empleados: t.total_empleados, 
        desbloqueados: 0, // Al ser tiendas de prueba nuevas, empiezan en 0 estrellas
        activa: t.activa
      };
    });

    res.json({ tiendas: tiendasProcesadas });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interno en la base de datos al leer el volumen.' });
  }
});

module.exports = router;
