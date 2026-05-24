require('dotenv').config();
const cron                = require('node-cron');
const { createClient }    = require('@supabase/supabase-js');
const { leerDatosVentas } = require('./googlesheets');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

async function procesarVentasSemanales() {
  console.log(`[${new Date().toISOString()}] Iniciando procesamiento masivo semanal...`);

  try {
    const { data: semana, error: errSem } = await supabase
      .from('semanas')
      .select('*')
      .eq('activa', true)
      .single();

    if (errSem || !semana) {
      console.warn('[Scheduler] No hay ninguna semana configurada como activa.');
      return;
    }

    const datosVentas = await leerDatosVentas();
    if (!datosVentas.length) return console.log('[Scheduler] Google Sheets está vacío.');

    // TRAEMOS TODOS LOS EMPLEADOS ACTIVOS DE UNA SOLA VEZ (Evita el cuello de botella N+1)
    const { data: todosLosEmpleados } = await supabase
      .from('empleados')
      .select('id, nombre, semana_asignada, activo, sheets_row_id')
      .eq('activo', true);

    const empleadoMap = new Map(todosLosEmpleados.map(e => [e.sheets_row_id, e]));
    
    const resultadosParaUpsert = [];
    const empleadosParaInactivar = [];

    for (const dato of datosVentas) {
      const empleado = empleadoMap.get(dato.sheetsId);
      if (!empleado) continue;

      if (!dato.activo) {
        empleadosParaInactivar.push(empleado.id);
        continue;
      }

      if (dato.semana !== semana.numero || empleado.semana_asignada !== semana.numero) continue;

      resultadosParaUpsert.push({
        empleado_id:         empleado.id,
        semana_id:           semana.id,
        porcentaje_cumplido: dato.porcentaje,
        cumplio_meta:        dato.porcentaje >= 100,
        fecha_registro:      new Date().toISOString(),
      });
    }

    // Guardado eficiente en bloques masivos
    if (empleadosParaInactivar.length > 0) {
      await supabase.from('empleados').update({ activo: false }).in('id', empleadosParaInactivar);
    }

    if (resultadosParaUpsert.length > 0) {
      await supabase.from('resultados_ventas').upsert(resultadosParaUpsert, { onConflict: 'empleado_id,semana_id' });
    }

    // Ejecuta la optimización automática que programaste en tu Postgres de Supabase
    await supabase.rpc('desbloquear_espacios_automatico');
    console.log('[Scheduler] Sincronización masiva finalizada con éxito.');

  } catch (err) {
    console.error('[Scheduler] Error crítico:', err.message);
  }
}

function iniciarScheduler() {
  // Se ejecuta todos los lunes a las 6:00 AM hora Bogotá automáticamente
  cron.schedule('0 6 * * 1', procesarVentasSemanales, {
    timezone: 'America/Bogota',
  });
  console.log('[Scheduler] Automatización encendida (Cada Lunes 6:00am Bogotá).');
}

module.exports = { iniciarScheduler, procesarVentasSemanales };
