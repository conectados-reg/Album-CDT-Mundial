const router = require('express').Router();
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function verificarSyncKey(req, res, next) {
  const key = req.headers['x-sync-key'];
  if (!key || !process.env.SYNC_KEY || key !== process.env.SYNC_KEY) {
    return res.status(401).json({ error: 'Clave de sincronización inválida.' });
  }
  next();
}

/**
 * POST /api/sync/registrar-tienda
 * Crea la tienda si no existe, sin crear resultados ni fichas.
 * Body: { tienda_codigo, nombre, pais }
 */
router.post('/registrar-tienda', verificarSyncKey, async (req, res) => {
  const { tienda_codigo, nombre, pais, total_empleados } = req.body;
  if (!tienda_codigo || !nombre) {
    return res.status(400).json({ error: 'Faltan campos: tienda_codigo, nombre.' });
  }

  const nuevoHC = parseInt(total_empleados);
  const hcValido = !isNaN(nuevoHC) && nuevoHC > 0;

  try {
    const { data: existente } = await supabase
      .from('tiendas')
      .select('id, nombre, total_empleados')
      .eq('codigo', tienda_codigo.toString().trim())
      .maybeSingle();

    if (existente) {
      if (hcValido && nuevoHC !== existente.total_empleados) {
        await supabase.from('tiendas').update({ total_empleados: nuevoHC }).eq('id', existente.id);
      }
      return res.json({ ok: true, creada: false, tienda: existente.nombre });
    }

    const emailAuto = `${tienda_codigo.toString().trim().toLowerCase()}@sportline.com`;
    const { error: cErr } = await supabase.from('tiendas').insert({
      codigo:          tienda_codigo.toString().trim(),
      nombre:          nombre.toString().trim(),
      region:          (pais || 'General').toString().trim(),
      email:           emailAuto,
      password_hash:   'sport123',
      activa:          true,
      total_empleados: hcValido ? nuevoHC : 0
    });

    if (cErr && !cErr.message.includes('duplicate key')) {
      return res.status(500).json({ error: 'No se pudo crear la tienda: ' + cErr.message });
    }

    res.json({ ok: true, creada: true, tienda: nombre.toString().trim() });
  } catch (err) {
    console.error('[Registrar Tienda]', err.message);
    res.status(500).json({ error: err.message });
  }
});

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

    if (!tienda) {
      const { nombre, pais } = req.body;
      if (!nombre) return res.status(404).json({ error: `Tienda "${tienda_codigo}" no encontrada. Incluye "nombre" en el payload para crearla.` });

      const emailAuto = `${tienda_codigo.toString().trim().toLowerCase()}@sportline.com`;

      const { error: cErr } = await supabase
        .from('tiendas')
        .insert({
          codigo:          tienda_codigo.toString().trim(),
          nombre:          nombre.toString().trim(),
          region:          (pais || 'General').toString().trim(),
          email:           emailAuto,
          password_hash:   'sport123',
          activa:          true,
          total_empleados: 0
        });

      if (cErr && !cErr.message.includes('duplicate key')) {
        return res.status(500).json({ error: 'No se pudo crear la tienda: ' + cErr.message });
      }

      const { data: tiendaReloaded } = await supabase
        .from('tiendas')
        .select('id, nombre, total_empleados')
        .eq('codigo', tienda_codigo.toString().trim())
        .single();

      tienda = tiendaReloaded;
    }

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

    const { error: upsertErr } = await supabase.from('resultados_tienda').upsert(
      { tienda_id: tienda.id, semana_id: semana.id, porcentaje_cumplido: pct },
      { onConflict: 'tienda_id,semana_id' }
    );
    if (upsertErr) throw new Error('Error guardando resultado: ' + upsertErr.message);

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
