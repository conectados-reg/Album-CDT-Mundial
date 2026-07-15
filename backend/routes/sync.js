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

    const nuevoPromedio = parseFloat(req.body.promedio);
    if (!isNaN(nuevoPromedio)) {
      await supabase.from('tiendas').update({ promedio_ranking: nuevoPromedio }).eq('id', tienda.id);
    }

    const { data: semana, error: sErr } = await supabase
      .from('semanas')
      .select('id, numero')
      .eq('numero', parseInt(semanaNum))
      .maybeSingle();

    if (sErr || !semana) return res.status(404).json({ error: `Semana ${semanaNum} no encontrada.` });

    const pct = parseFloat(porcentaje) || 0;

    // DELETE + INSERT en lugar de upsert para evitar duplicados
    await supabase.from('resultados_tienda')
      .delete()
      .eq('tienda_id', tienda.id)
      .eq('semana_id', semana.id);

    const { error: insertErr } = await supabase.from('resultados_tienda').insert(
      { tienda_id: tienda.id, semana_id: semana.id, porcentaje_cumplido: pct }
    );
    if (insertErr) throw new Error('Error guardando resultado: ' + insertErr.message);

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

/**
 * POST /api/sync/resultados-batch
 * Recibe TODOS los resultados en una sola petición para evitar timeouts del GAS.
 * Body: { resultados: [{ tienda_codigo, semana, porcentaje, nombre, pais, total_empleados, promedio? }] }
 */
router.post('/resultados-batch', verificarSyncKey, async (req, res) => {
  const { resultados } = req.body;
  if (!Array.isArray(resultados) || resultados.length === 0) {
    return res.status(400).json({ error: 'Envía un array "resultados" con al menos un elemento.' });
  }

  try {
    // Traer semanas y TODAS las tiendas (no usar .in() con 250+ codigos — puede truncarse)
    const [
      { data: semanas, error: sErr },
      { data: tiendas, error: tErr },
    ] = await Promise.all([
      supabase.from('semanas').select('id, numero').order('numero'),
      supabase.from('tiendas').select('id, codigo, nombre, total_empleados'),
    ]);
    if (sErr) throw sErr;
    if (tErr) throw tErr;

    const semanaByNum = {};
    for (const s of (semanas || [])) semanaByNum[s.numero] = s.id;

    const tiendaByCode = {};
    for (const t of (tiendas || [])) tiendaByCode[t.codigo] = t;

    // Parsear y validar registros
    const errores = [];
    const validRows = [];
    const hcUpdates = {};
    const promedioUpdates = {};

    for (const r of resultados) {
      const codigo   = r.tienda_codigo?.toString().trim();
      const tienda   = tiendaByCode[codigo];
      if (!tienda) { errores.push('Tienda "' + codigo + '" no encontrada.'); continue; }

      const semanaNum = parseInt(r.semana);
      const semanaId  = semanaByNum[semanaNum];
      if (!semanaId) { errores.push('Semana ' + semanaNum + ' no existe.'); continue; }

      const pct = parseFloat(r.porcentaje) || 0;
      validRows.push({ tienda_id: tienda.id, semana_id: semanaId, porcentaje_cumplido: pct });

      const nuevoHC = parseInt(r.total_empleados);
      if (!isNaN(nuevoHC) && nuevoHC > 0 && nuevoHC !== tienda.total_empleados) {
        hcUpdates[tienda.id] = nuevoHC;
      }
      const nuevoPromedio = parseFloat(r.promedio);
      if (!isNaN(nuevoPromedio)) {
        promedioUpdates[tienda.id] = nuevoPromedio;
      }
    }

    // Procesar por semana: DELETE masivo → INSERT masivo → desbloquear fichas
    const bySemana = {};
    for (const row of validRows) {
      if (!bySemana[row.semana_id]) bySemana[row.semana_id] = [];
      bySemana[row.semana_id].push(row);
    }

    let fichasDesbloqueadas = 0;
    for (const [semanaId, rows] of Object.entries(bySemana)) {
      // Borrar TODOS los resultados de la semana antes de reinsertar.
      // No usar .in(tiendaIds) — con 248+ UUIDs supera el límite de URL de PostgREST.
      await supabase.from('resultados_tienda').delete().eq('semana_id', semanaId);

      const { error: insertErr } = await supabase.from('resultados_tienda').insert(rows);
      if (insertErr) throw new Error('Error insertando resultados semana ' + semanaId + ': ' + insertErr.message);

      const ids100 = rows.filter(r => r.porcentaje_cumplido >= 100).map(r => r.tienda_id);
      if (ids100.length > 0) {
        const { data: desbloqueadas } = await supabase.from('fichas_tienda')
          .update({ desbloqueado: true, fecha_desbloqueo: new Date().toISOString() })
          .eq('semana_id', semanaId).in('tienda_id', ids100).eq('desbloqueado', false)
          .select('id');
        fichasDesbloqueadas += desbloqueadas?.length || 0;
      }
    }

    // Actualizar HC y promedio en lotes de 20 paralelos
    const tiendaUpdateIds = [...new Set([...Object.keys(hcUpdates), ...Object.keys(promedioUpdates)])];
    for (let i = 0; i < tiendaUpdateIds.length; i += 20) {
      await Promise.all(tiendaUpdateIds.slice(i, i + 20).map(id => {
        const upd = {};
        if (hcUpdates[id] != null)       upd.total_empleados = hcUpdates[id];
        if (promedioUpdates[id] != null) upd.promedio_ranking = promedioUpdates[id];
        return supabase.from('tiendas').update(upd).eq('id', id);
      }));
    }

    res.json({
      ok: true,
      procesadas: validRows.length,
      errores: errores.length,
      fichas_desbloqueadas: fichasDesbloqueadas,
      detalle_errores: errores.slice(0, 20),
    });

  } catch (err) {
    console.error('[Sync Batch]', err.message);
    res.status(500).json({ error: 'Error en sincronización batch: ' + err.message });
  }
});

module.exports = router;
