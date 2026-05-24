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

// Panel de control general para el Administrador
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Permiso denegado.' });

  // Trae todas las tiendas con una sola query limpia (Evita problemas de lentitud)
  const { data: resumen } = await supabase
    .from('tiendas')
    .select(`id, codigo, nombre, region, ciudad, total_empleados, empleados ( id, espacios_album (desbloqueado) )`)
    .eq('activa', true)
    .order('nombre');

  const tiendasProcesadas = (resumen || []).map(t => {
    let estrellasDesbloqueadas = 0;
    t.empleados.forEach(e => {
      if (e.espacios_album?.some(ea => ea.desbloqueado)) estrellasDesbloqueadas++;
    });
    return {
      id: t.id, codigo: t.codigo, nombre: t.nombre, region: t.region, ciudad: t.ciudad,
      total_empleados: t.total_empleados, desbloqueados: estrellasDesbloqueadas
    };
  });

  res.json({ tiendas: tiendasProcesadas });
});

module.exports = router;
