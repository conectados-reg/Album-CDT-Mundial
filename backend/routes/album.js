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

// GET /api/album — Empleados con desbloqueos acumulados de TODAS las semanas
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') {
    return res.status(403).json({ error: 'Solo para sucursales.' });
  }

  try {
    // Semana activa (solo para contexto/display)
    const { data: semana } = await supabase
      .from('semanas')
      .select('*')
      .eq('activa', true)
      .maybeSingle();

    // Cargar empleados con TODOS sus espacios de álbum (todas las semanas)
    const { data: empleados, error } = await supabase
      .from('empleados')
      .select('id, nombre, cargo, foto_url, espacios_album(desbloqueado, semana_id)')
      .eq('tienda_id', req.usuario.id)
      .eq('activo', true)
      .order('nombre');

    if (error) throw error;

    // Porcentaje de la semana activa (si existe)
    const empIds = (empleados || []).map(e => e.id);
    const pctMap = {};
    if (empIds.length && semana) {
      const { data: resultados } = await supabase
        .from('resultados_ventas')
        .select('empleado_id, porcentaje_cumplido')
        .eq('semana_id', semana.id)
        .in('empleado_id', empIds);
      for (const r of (resultados || [])) pctMap[r.empleado_id] = r.porcentaje_cumplido;
    }

    const resultado = (empleados || []).map((emp, idx) => {
      const espacios = emp.espacios_album || [];
      // Desbloqueado si cumplió meta en CUALQUIER semana (pasada o activa)
      const desbloqueado = espacios.some(e => e.desbloqueado === true);
      // Semanas donde ganó estrella
      const semanasGanadas = espacios.filter(e => e.desbloqueado).map(e => e.semana_id);

      return {
        id: emp.id,
        numero: idx + 1,
        nombre: emp.nombre,
        cargo: emp.cargo || 'Asesor de Ventas',
        foto_url: emp.foto_url || null,
        desbloqueado,
        semanas_ganadas: semanasGanadas.length,
        porcentaje: pctMap[emp.id] ?? null,
      };
    });

    res.json({
      empleados: resultado,
      semana: semana ? {
        numero: semana.numero,
        nombre: semana.nombre,
        fecha_inicio: semana.fecha_inicio,
        fecha_fin: semana.fecha_fin,
      } : null,
      total: resultado.length,
      desbloqueados: resultado.filter(e => e.desbloqueado).length,
    });

  } catch (err) {
    console.error('[Album]', err.message);
    res.status(500).json({ error: 'Error al cargar el álbum.' });
  }
});

// POST /api/album/foto — subir foto (permitido si desbloqueó en CUALQUIER semana)
router.post('/foto', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  const { empleado_id, foto_base64, tipo } = req.body;
  if (!empleado_id || !foto_base64) return res.status(400).json({ error: 'Datos incompletos.' });

  try {
    const { data: emp } = await supabase
      .from('empleados').select('tienda_id').eq('id', empleado_id).single();
    if (!emp || emp.tienda_id !== req.usuario.id) {
      return res.status(403).json({ error: 'Sin permiso sobre este empleado.' });
    }

    // Verificar que desbloqueó en AL MENOS UNA semana
    const { data: espacios } = await supabase
      .from('espacios_album')
      .select('desbloqueado')
      .eq('empleado_id', empleado_id)
      .eq('desbloqueado', true)
      .limit(1);

    if (!espacios?.length) {
      return res.status(403).json({ error: 'El empleado no ha desbloqueado ninguna figurita aún.' });
    }

    const buffer = Buffer.from(foto_base64, 'base64');
    const ext = (tipo || '').includes('png') ? 'png' : 'jpg';
    const filename = `${empleado_id}.${ext}`;

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
