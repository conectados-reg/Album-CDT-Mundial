const router = require('express').Router();
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function verificarSyncKey(req, res, next) {
  const key = req.headers['x-sync-key'];
  if (!key || key !== (process.env.SYNC_KEY || 'sync-sportline-2026')) {
    return res.status(401).json({ error: 'Clave de sincronización inválida.' });
  }
  next();
}

/**
 * POST /api/sync/resultados
 * Llamado desde Google Apps Script.
 * Body: { tienda_codigo: "1107", semana: 1, porcentaje: 99.04, total_empleados: 12 }
 * total_empleados es opcional — si se envía, actualiza la tienda y recalcula fichas.
 */
router.post('/resultados', verificarSyncKey, async (req, res) => {
  const { tienda_codigo, semana: semanaNum, porcentaje, total_empleados } = req.body;

  if (!tienda_codigo || semanaNum == null || porcentaje == null) {
    return res.status(400).json({ error: 'Faltan campos: tienda_codigo, semana, porcentaje.' });
  }

  try {
    const { data: tiendaEncontrada, error: tErr } = await supabase
      .from('tiendas')
      .select('id, nombre, total_empleados')
      .eq('codigo', tienda_codigo.toString().trim())
      .maybeSingle();

    if (tErr) return res.status(500).json({ error: tErr.message });

    let tienda = tiendaEncontrada;

    // Si la tienda no existe, crearla automáticamente con los datos del Sheet
    if (!tienda) {
      const { nombre, pais } = req.body;
      if (!nombre) return res.status(404).json({ error: `Tienda "${tienda_codigo}" no encontrada. Incluye "nombre" en el payload para crearla.` });

      const emailAuto = `${tienda_codigo.toString().trim().toLowerCase()}@sportline.com`;
      const { data: nueva, error: cErr } = await supabase
        .from('tiendas')
        .insert({
          codigo:          tienda_codigo.toString().trim(),
          nombre:          nombre.toString().trim(),
          region:          (pais || 'General').toString().trim(),
          email:           emailAuto,
          password_hash:   'sport123',
          activa:          true,
          total_empleados: 0
        })
        .select('id, nombre, total_empleados')
        .single();

      if (cErr) return res.status(500).json({ error: 'No se pudo crear la tienda: ' + cErr.message });
      tienda = nueva;
    }

    // Actualizar total_empleados si viene en el payload y es diferente al actual
    const nuevoTotal = parseInt(total_empleados);
    if (!isNaN(nuevoTotal) && nuevoTotal > 0 && nuevoTotal !== tienda.total_empleados) {
      await supabase
        .from('tiendas')
        .update({ total_empleados: nuevoTotal })
        .eq('id', tienda.id);
    }

    const { data: semana, error: sErr } = await supabase
      .from('semanas')
      .select('id, numero')
      .eq('numero', parseInt(semanaNum))
      .maybeSingle();

    if (sErr || !semana) return res.status(404).json({ error: `Semana ${semanaNum} no encontrada.` });

    const pct = parseFloat(porcentaje) || 0;

    await supabase.from('resultados_tienda').upsert(
      { tienda_id: tienda.id, semana_id: semana.id, porcentaje_cumplido: pct, cumplio_meta: pct >= 100, updated_at: new Date().toISOString() },
      { onConflict: 'tienda_id,semana_id' }
    );

    // Desbloquear fichas si llega al 100% (redundante con el trigger, pero garantiza consistencia)
    let desbloqueadas = 0;
    if (pct >= 100) {
      const { data: actualizadas } = await supabase
        .from('fichas_tienda')
        .update({ desbloqueado: true, fecha_desbloqueo: new Date().toISOString() })
        .eq('tienda_id', tienda.id)
        .eq('semana_id', semana.id)
        .eq('desbloqueado', false)
        .select('id');
      desbloqueadas = actualizadas?.length || 0;
    }

    res.json({ ok: true, tienda: tienda.nombre, semana: semana.numero, porcentaje: pct, fichas_desbloqueadas: desbloqueadas, total_empleados: !isNaN(nuevoTotal) && nuevoTotal > 0 ? nuevoTotal : tienda.total_empleados });

  } catch (err) {
    console.error('[Sync Resultados]', err.message);
    res.status(500).json({ error: 'Error en sincronización: ' + err.message });
  }
});

module.exports = router;
