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

// GET /api/album — Una tarjeta por cada semana que el empleado cumplió meta
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') {
    return res.status(403).json({ error: 'Solo para sucursales.' });
  }

  try {
    // Semana activa para contexto
    const { data: semanaActiva } = await supabase
      .from('semanas').select('numero, nombre').eq('activa', true).maybeSingle();

    // Todos los empleados activos de la tienda con TODOS sus espacios
    const { data: empleados, error } = await supabase
      .from('empleados')
      .select('id, nombre, cargo, foto_url, espacios_album(id, semana_id, desbloqueado)')
      .eq('tienda_id', req.usuario.id)
      .eq('activo', true)
      .order('nombre');

    if (error) throw error;

    // Mapa de semanas
    const { data: semanas } = await supabase
      .from('semanas').select('id, numero, nombre').order('numero');
    const semanaMap = {};
    for (const s of (semanas || [])) semanaMap[s.id] = s;

    // Porcentajes de todas las semanas
    const empIds = (empleados || []).map(e => e.id);
    const pctMap = {};
    if (empIds.length) {
      const { data: resultados } = await supabase
        .from('resultados_ventas')
        .select('empleado_id, semana_id, porcentaje_cumplido')
        .in('empleado_id', empIds);
      for (const r of (resultados || [])) {
        pctMap[`${r.empleado_id}-${r.semana_id}`] = r.porcentaje_cumplido;
      }
    }

    // Construir resultado: una entrada por espacio desbloqueado + una entrada locked por empleado sin desbloqueos
    const resultado = [];
    let contador = 1;

    for (const emp of (empleados || [])) {
      const espacios = emp.espacios_album || [];
      const desbloqueados = espacios
        .filter(e => e.desbloqueado)
        .sort((a, b) => (semanaMap[a.semana_id]?.numero || 0) - (semanaMap[b.semana_id]?.numero || 0));

      if (desbloqueados.length > 0) {
        // Una tarjeta por cada semana cumplida
        for (const esp of desbloqueados) {
          const sem = semanaMap[esp.semana_id] || {};
          resultado.push({
            id: emp.id,
            espacio_id: esp.id,
            numero: contador++,
            nombre: emp.nombre,
            cargo: emp.cargo || 'Asesor de Ventas',
            foto_url: emp.foto_url || null,
            desbloqueado: true,
            semana_id: esp.semana_id,
            semana_numero: sem.numero || null,
            semana_nombre: sem.nombre || null,
            porcentaje: pctMap[`${emp.id}-${esp.semana_id}`] ?? null,
          });
        }
      } else {
        // Tarjeta bloqueada única
        resultado.push({
          id: emp.id,
          espacio_id: null,
          numero: contador++,
          nombre: emp.nombre,
          cargo: emp.cargo || 'Asesor de Ventas',
          foto_url: null,
          desbloqueado: false,
          semana_id: null,
          semana_numero: null,
          semana_nombre: null,
          porcentaje: null,
        });
      }
    }

    res.json({
      empleados: resultado,
      semana: semanaActiva || null,
      total: resultado.length,
      desbloqueados: resultado.filter(e => e.desbloqueado).length,
    });

  } catch (err) {
    console.error('[Album]', err.message);
    res.status(500).json({ error: 'Error al cargar el álbum.' });
  }
});

// POST /api/album/foto — subir foto al empleado (persiste en todas sus semanas)
router.post('/foto', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  const { empleado_id, foto_base64, tipo } = req.body;
  if (!empleado_id || !foto_base64) return res.status(400).json({ error: 'Datos incompletos.' });

  try {
    // Verificar que el empleado pertenece a la tienda y tiene algún desbloqueo
    const { data: emp } = await supabase
      .from('empleados').select('tienda_id').eq('id', empleado_id).single();
    if (!emp || emp.tienda_id !== req.usuario.id) {
      return res.status(403).json({ error: 'Sin permiso sobre este empleado.' });
    }

    const { data: espacios } = await supabase
      .from('espacios_album')
      .select('id')
      .eq('empleado_id', empleado_id)
      .eq('desbloqueado', true)
      .limit(1);
    if (!espacios?.length) {
      return res.status(403).json({ error: 'El empleado no ha desbloqueado ninguna figurita.' });
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
