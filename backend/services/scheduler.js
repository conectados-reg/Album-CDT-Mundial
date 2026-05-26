require('dotenv').config();
const cron = require('node-cron');
const db   = require('../db');
const { leerDatosVentas } = require('./googlesheets');

async function procesarVentasSemanales() {
  console.log(`[${new Date().toISOString()}] Iniciando procesamiento masivo semanal...`);

  try {
    const semana = await db.one('SELECT * FROM semanas WHERE activa = true LIMIT 1');
    if (!semana) {
      console.warn('[Scheduler] No hay ninguna semana configurada como activa.');
      return;
    }

    const datosVentas = await leerDatosVentas();
    if (!datosVentas.length) return console.log('[Scheduler] Google Sheets está vacío.');

    const todosLosEmpleados = await db.all(
      'SELECT id, nombre, semana_asignada, activo, sheets_row_id FROM empleados WHERE activo = true'
    );
    const empleadoMap = new Map(todosLosEmpleados.map(e => [e.sheets_row_id, e]));

    const resultadosParaUpsert   = [];
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
      });
    }

    if (empleadosParaInactivar.length) {
      await db.query('UPDATE empleados SET activo = false WHERE id = ANY($1)', [empleadosParaInactivar]);
    }

    if (resultadosParaUpsert.length) {
      const BATCH = 100;
      for (let i = 0; i < resultadosParaUpsert.length; i += BATCH) {
        const chunk = resultadosParaUpsert.slice(i, i + BATCH);
        const vals  = db.buildValues(chunk, 4);
        const pms   = chunk.flatMap(r => [r.empleado_id, r.semana_id, r.porcentaje_cumplido, r.cumplio_meta]);
        await db.query(
          `INSERT INTO resultados_ventas (empleado_id, semana_id, porcentaje_cumplido, cumplio_meta, fecha_registro)
           VALUES ${vals.replace(/\(([^)]+)\)/g, '($1, NOW())')}
           ON CONFLICT (empleado_id, semana_id) DO UPDATE SET
             porcentaje_cumplido = EXCLUDED.porcentaje_cumplido,
             cumplio_meta = EXCLUDED.cumplio_meta`,
          pms
        );
      }
    }

    // Ejecuta la función PL/pgSQL que desbloquea espacios automáticamente
    await db.query('SELECT desbloquear_espacios_automatico()');
    console.log('[Scheduler] Sincronización masiva finalizada con éxito.');

  } catch (err) {
    console.error('[Scheduler] Error crítico:', err.message);
  }
}

function iniciarScheduler() {
  cron.schedule('0 6 * * 1', procesarVentasSemanales, {
    timezone: 'America/Bogota',
  });
  console.log('[Scheduler] Automatización encendida (Cada Lunes 6:00am Bogotá).');
}

module.exports = { iniciarScheduler, procesarVentasSemanales };
