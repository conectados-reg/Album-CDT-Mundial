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

function normalizarNombre(n) {
  return (n || '').trim().toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
}

/**
 * POST /api/sync/ventas
 * Llamado desde Google Apps Script.
 * Body: {
 *   semana: 1,                         // número de semana (1-6)
 *   tienda_codigo: "SL-PA-001",
 *   empleados: [
 *     { nombre: "María García", cargo: "Asesora", activo: true,  porcentaje: 107.5 },
 *     { nombre: "Juan López",   cargo: "Vendedor", activo: false, porcentaje: 0    }
 *   ]
 * }
 */
router.post('/ventas', verificarSyncKey, async (req, res) => {
  const { semana: semanaNum, tienda_codigo, empleados } = req.body;

  if (!tienda_codigo || !Array.isArray(empleados) || !semanaNum) {
    return res.status(400).json({ error: 'Faltan campos: semana, tienda_codigo, empleados.' });
  }

  try {
    // 1. Buscar tienda
    const { data: tienda, error: tErr } = await supabase
      .from('tiendas')
      .select('id, nombre')
      .eq('codigo', tienda_codigo.trim().toUpperCase())
      .maybeSingle();

    if (tErr) {
      return res.status(500).json({ error: `Error DB al buscar tienda: ${tErr.message}`, codigo: tienda_codigo });
    }
    if (!tienda) {
      return res.status(404).json({ error: `Tienda "${tienda_codigo}" no encontrada.`, buscado: tienda_codigo.trim().toUpperCase() });
    }

    // 2. Buscar semana por número
    const { data: semana, error: sErr } = await supabase
      .from('semanas')
      .select('id, numero')
      .eq('numero', parseInt(semanaNum))
      .maybeSingle();

    if (sErr || !semana) {
      return res.status(404).json({ error: `Semana ${semanaNum} no encontrada. Crea las 6 semanas primero.` });
    }

    // 3. Cargar empleados actuales de la tienda
    const { data: empActuales } = await supabase
      .from('empleados')
      .select('id, nombre, activo')
      .eq('tienda_id', tienda.id);

    const empMap = {};
    for (const e of (empActuales || [])) {
      empMap[normalizarNombre(e.nombre)] = e;
    }

    const stats = { creados: 0, desactivados: 0, actualizados: 0, desbloqueados: 0, bloqueados: 0 };

    for (const fila of empleados) {
      const nombreNorm = normalizarNombre(fila.nombre);
      const activo     = fila.activo === true || fila.activo === 'TRUE' || fila.activo === 1;
      const porcentaje = parseFloat(fila.porcentaje) || 0;
      const cargo      = (fila.cargo || 'Asesor de Ventas').trim();

      let emp = empMap[nombreNorm];

      // Empleado no existe → crearlo (solo si activo)
      if (!emp && activo) {
        const { data: nuevo } = await supabase
          .from('empleados')
          .insert({ tienda_id: tienda.id, nombre: fila.nombre.trim(), cargo, activo: true, semana_asignada: 1 })
          .select('id, nombre, activo')
          .single();
        if (nuevo) { emp = nuevo; empMap[nombreNorm] = nuevo; stats.creados++; }
      }

      if (!emp) continue;

      // Empleado inactivo → desactivar
      if (!activo && emp.activo !== false) {
        await supabase.from('empleados').update({ activo: false }).eq('id', emp.id);
        // Eliminar su espacio de esta semana
        await supabase.from('espacios_album').delete()
          .eq('empleado_id', emp.id).eq('semana_id', semana.id);
        // Eliminar resultado de ventas de esta semana
        await supabase.from('resultados_ventas').delete()
          .eq('empleado_id', emp.id).eq('semana_id', semana.id);
        stats.desactivados++;
        continue;
      }

      if (!activo) continue; // ya estaba inactivo

      // Reactivar si estaba inactivo
      if (emp.activo === false) {
        await supabase.from('empleados').update({ activo: true }).eq('id', emp.id);
      }

      // Registrar resultado de ventas
      await supabase.from('resultados_ventas').upsert(
        { empleado_id: emp.id, semana_id: semana.id, porcentaje_cumplido: porcentaje, cumplio_meta: porcentaje >= 100 },
        { onConflict: 'empleado_id,semana_id' }
      );
      stats.actualizados++;

      // Desbloquear o bloquear espacio del álbum
      if (porcentaje >= 100) {
        await supabase.from('espacios_album').upsert(
          { empleado_id: emp.id, semana_id: semana.id, desbloqueado: true, fecha_desbloqueo: new Date().toISOString() },
          { onConflict: 'empleado_id,semana_id' }
        );
        stats.desbloqueados++;
      } else {
        // Solo crear el espacio bloqueado si no existe uno todavía.
        // ignoreDuplicates:true garantiza que nunca se sobreescriba un desbloqueo previo.
        await supabase.from('espacios_album').upsert(
          { empleado_id: emp.id, semana_id: semana.id, desbloqueado: false },
          { onConflict: 'empleado_id,semana_id', ignoreDuplicates: true }
        );
        stats.bloqueados++;
      }
    }

    // Actualizar conteo de empleados activos en la tienda
    const { count } = await supabase
      .from('empleados').select('id', { count: 'exact', head: true })
      .eq('tienda_id', tienda.id).eq('activo', true);
    await supabase.from('tiendas').update({ total_empleados: count || 0 }).eq('id', tienda.id);

    res.json({ ok: true, tienda: tienda.nombre, semana: semana.numero, ...stats });

  } catch (err) {
    console.error('[Sync Ventas]', err.message);
    res.status(500).json({ error: 'Error en sincronización: ' + err.message });
  }
});

module.exports = router;
