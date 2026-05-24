const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function verificarToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token faltante.' });
  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET || 'secretomocal123');
    next();
  } catch {
    res.status(401).json({ error: 'Sesión inválida.' });
  }
}

// GET /api/album — Devuelve empleados de la tienda con su estado de desbloqueo en la semana activa
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') {
    return res.status(403).json({ error: 'Solo para sucursales.' });
  }

  try {
    const { data: semana } = await supabase
      .from('semanas')
      .select('*')
      .eq('activa', true)
      .single();

    if (!semana) {
      return res.json({ empleados: [], semana: null, total: 0, desbloqueados: 0 });
    }

    const { data: empleados, error } = await supabase
      .from('empleados')
      .select('id, nombre, cargo, foto_url, semana_asignada, espacios_album(desbloqueado, semana_id)')
      .eq('tienda_id', req.usuario.id)
      .eq('activo', true)
      .eq('semana_asignada', semana.numero);

    if (error) throw error;

    const resultado = (empleados || []).map((emp, idx) => {
      const espacio = (emp.espacios_album || []).find(e => e.semana_id === semana.id);
      return {
        id: emp.id,
        numero: idx + 1,
        nombre: emp.nombre,
        cargo: emp.cargo || 'Asesor de Ventas',
        foto_url: emp.foto_url || null,
        desbloqueado: espacio?.desbloqueado || false,
      };
    });

    res.json({
      empleados: resultado,
      semana: {
        numero: semana.numero,
        nombre: semana.nombre,
        fecha_inicio: semana.fecha_inicio,
        fecha_fin: semana.fecha_fin,
      },
      total: resultado.length,
      desbloqueados: resultado.filter(e => e.desbloqueado).length,
    });

  } catch (err) {
    console.error('[Album]', err.message);
    res.status(500).json({ error: 'Error al cargar el álbum.' });
  }
});

module.exports = router;
