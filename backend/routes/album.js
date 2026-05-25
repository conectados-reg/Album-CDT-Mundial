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
      .select('id, nombre, cargo, foto_url, espacios_album(desbloqueado, semana_id)')
      .eq('tienda_id', req.usuario.id)
      .eq('activo', true)
      .order('nombre');

    if (error) throw error;

    const empIds = (empleados || []).map(e => e.id);
    const { data: resultados } = empIds.length
      ? await supabase.from('resultados_ventas')
          .select('empleado_id, porcentaje_cumplido')
          .eq('semana_id', semana.id)
          .in('empleado_id', empIds)
      : { data: [] };

    const pctMap = {};
    for (const r of (resultados || [])) pctMap[r.empleado_id] = r.porcentaje_cumplido;

    const resultado = (empleados || []).map((emp, idx) => {
      const espacio = (emp.espacios_album || []).find(e => e.semana_id === semana.id);
      return {
        id: emp.id,
        numero: idx + 1,
        nombre: emp.nombre,
        cargo: emp.cargo || 'Asesor de Ventas',
        foto_url: emp.foto_url || null,
        desbloqueado: espacio?.desbloqueado || false,
        porcentaje: pctMap[emp.id] ?? null,
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

// POST /api/album/foto — subir foto para espacio desbloqueado en la semana activa
router.post('/foto', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  const { empleado_id, foto_base64, tipo } = req.body;
  if (!empleado_id || !foto_base64) return res.status(400).json({ error: 'Datos incompletos.' });

  try {
    const { data: semana } = await supabase
      .from('semanas').select('id').eq('activa', true).single();
    if (!semana) return res.status(400).json({ error: 'No hay semana activa.' });

    const { data: emp } = await supabase
      .from('empleados').select('tienda_id').eq('id', empleado_id).single();
    if (!emp || emp.tienda_id !== req.usuario.id) {
      return res.status(403).json({ error: 'Sin permiso sobre este empleado.' });
    }

    const { data: espacio } = await supabase
      .from('espacios_album')
      .select('desbloqueado')
      .eq('empleado_id', empleado_id)
      .eq('semana_id', semana.id)
      .single();
    if (!espacio?.desbloqueado) {
      return res.status(403).json({ error: 'El espacio no está desbloqueado esta semana.' });
    }

    const buffer = Buffer.from(foto_base64, 'base64');
    const ext = (tipo || '').includes('png') ? 'png' : 'jpg';
    const filename = `${empleado_id}-s${semana.id}.${ext}`;

    const { error: uploadError } = await supabase.storage
      .from('fotos-empleados')
      .upload(filename, buffer, { contentType: tipo || 'image/jpeg', upsert: true });
    if (uploadError) throw uploadError;

    const { data: urlData } = supabase.storage.from('fotos-empleados').getPublicUrl(filename);
    const fotoUrl = urlData.publicUrl;

    await supabase.from('empleados').update({ foto_url: fotoUrl }).eq('id', empleado_id);

    res.json({ ok: true, foto_url: fotoUrl });
  } catch (err) {
    console.error('[Foto]', err.message);
    res.status(500).json({ error: 'Error al subir foto: ' + err.message });
  }
});

module.exports = router;
