const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function calcularDistribucion(hc) {
  const total = hc <= 6 ? 6 : hc;
  const base = Math.floor(total / 6);
  const extra = total % 6;
  return Array.from({ length: 6 }, (_, i) => (i < extra ? base + 1 : base));
}

function verificarToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token faltante.' });
  
  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (error) {
    res.status(401).json({ error: 'Sesión inválida.' });
  }
}

// GET /api/tiendas/lista — público, solo nombre/email/region para el dropdown del login
router.get('/lista', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('tiendas')
      .select('email, nombre, region, codigo')
      .eq('activa', true)
      .order('region', { nullsFirst: false })
      .order('nombre');
    if (error) throw error;
    res.json({ tiendas: data || [] });
  } catch (err) {
    console.error('[Tiendas Lista]', err.message);
    res.status(500).json({ error: 'Error al cargar tiendas.' });
  }
});

// GET /api/tiendas/ — admin: lista completa con datos sensibles
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') {
    return res.status(403).json({ error: 'No eres administrador.' });
  }

  try {
    const { data: tiendas, error } = await supabase
      .from('tiendas')
      .select('id, codigo, email, password_hash, nombre, region, ciudad, total_empleados, activa')
      .order('region', { nullsFirst: false })
      .order('nombre');

    if (error) throw error;

    // Traer TODAS las fichas en lotes para evitar el límite de 1000 filas de Supabase
    const fotosCount = {};
    const desbCount  = {};
    let desde = 0;
    const LOTE = 1000;
    while (true) {
      const { data: lote, error: lErr } = await supabase
        .from('fichas_tienda')
        .select('tienda_id, foto_url, desbloqueado')
        .range(desde, desde + LOTE - 1);
      if (lErr) { console.error('[Tiendas fotos_count] error lote', desde, lErr.message); break; }
      if (!lote || lote.length === 0) break;
      for (const f of lote) {
        if (f.foto_url)      fotosCount[f.tienda_id] = (fotosCount[f.tienda_id] || 0) + 1;
        if (f.desbloqueado)  desbCount[f.tienda_id]  = (desbCount[f.tienda_id]  || 0) + 1;
      }
      if (lote.length < LOTE) break;
      desde += LOTE;
    }

    const tiendasFormateadas = (tiendas || []).map(t => ({
      id: t.id,
      codigo: t.codigo,
      email: t.email || 'Sin correo',
      clave: t.password_hash,
      nombre: t.nombre,
      region: t.region || 'General',
      ciudad: t.ciudad || 'General',
      total_empleados: t.total_empleados || 0,
      activa: t.activa,
      fotos_count:          fotosCount[t.id] || 0,
      fichas_desbloqueadas: desbCount[t.id]  || 0,
    }));

    res.setHeader('Cache-Control', 'no-store');
    res.json({ tiendas: tiendasFormateadas });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error en la base de datos.' });
  }
});

// GET /api/tiendas/historial-claves — admin: tiendas que cambiaron su contraseña
router.get('/historial-claves', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') {
    return res.status(403).json({ error: 'No eres administrador.' });
  }

  try {
    const { data, error } = await supabase
      .from('tiendas')
      .select('id, codigo, nombre, region, password_changed_at')
      .not('password_changed_at', 'is', null)
      .order('password_changed_at', { ascending: false });

    if (error) throw error;
    res.json({ cambios: data || [] });
  } catch (err) {
    console.error('[Historial Claves]', err.message);
    res.status(500).json({ error: 'Error al obtener historial.' });
  }
});

// GET /api/tiendas/rankings — admin: ranking por porcentaje acumulativo
router.get('/rankings', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'No eres administrador.' });

  try {
    const { data: tiendas, error: tErr } = await supabase
      .from('tiendas')
      .select('id, codigo, nombre, region, total_empleados')
      .eq('activa', true);
    if (tErr) throw tErr;

    // Traer todos los resultados en lotes
    const todosResultados = [];
    let desde = 0;
    const LOTE = 1000;
    while (true) {
      const { data: lote, error: lErr } = await supabase
        .from('resultados_tienda')
        .select('tienda_id, porcentaje_cumplido')
        .range(desde, desde + LOTE - 1);
      if (lErr) throw lErr;
      if (!lote || lote.length === 0) break;
      todosResultados.push(...lote);
      if (lote.length < LOTE) break;
      desde += LOTE;
    }

    // Traer fotos_count por tienda
    const fotosCount = {};
    desde = 0;
    while (true) {
      const { data: lote, error: lErr } = await supabase
        .from('fichas_tienda')
        .select('tienda_id, foto_url')
        .not('foto_url', 'is', null)
        .range(desde, desde + LOTE - 1);
      if (lErr) break;
      if (!lote || lote.length === 0) break;
      for (const f of lote) {
        fotosCount[f.tienda_id] = (fotosCount[f.tienda_id] || 0) + 1;
      }
      if (lote.length < LOTE) break;
      desde += LOTE;
    }

    // Agrupar resultados por tienda
    const resPorTienda = {};
    for (const r of todosResultados) {
      if (!resPorTienda[r.tienda_id]) resPorTienda[r.tienda_id] = [];
      resPorTienda[r.tienda_id].push(r.porcentaje_cumplido);
    }

    const ranking = (tiendas || [])
      .map(t => {
        const semanas = resPorTienda[t.id] || [];
        const sumaTotal = semanas.reduce((a, b) => a + (b || 0), 0);
        const pct_acumulado = Math.round((sumaTotal / 6) * 10) / 10;
        const pct_promedio  = semanas.length
          ? Math.round((sumaTotal / semanas.length) * 10) / 10
          : 0;
        return {
          id:               t.id,
          codigo:           t.codigo,
          nombre:           t.nombre,
          region:           t.region || 'General',
          total_empleados:  t.total_empleados || 0,
          fotos_count:      fotosCount[t.id] || 0,
          semanas_con_data: semanas.length,
          pct_acumulado,
          pct_promedio,
        };
      })
      .filter(t => t.semanas_con_data > 0)
      .sort((a, b) => b.pct_acumulado - a.pct_acumulado || b.fotos_count - a.fotos_count);

    res.setHeader('Cache-Control', 'no-store');
    res.json({ ranking });
  } catch (err) {
    console.error('[Rankings]', err.message);
    res.status(500).json({ error: 'Error al calcular rankings: ' + err.message });
  }
});

// POST /api/tiendas/recalcular-todas — admin: audita y corrige fichas de todas las tiendas
router.post('/recalcular-todas', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'No eres administrador.' });

  const soloReportar = req.body.solo_reporte === true;

  try {
    const [
      { data: tiendas, error: tErr },
      { data: semanas, error: sErr },
    ] = await Promise.all([
      supabase.from('tiendas').select('id, codigo, nombre, total_empleados').order('nombre'),
      supabase.from('semanas').select('id, numero').order('numero'),
    ]);
    if (tErr) throw tErr;
    if (sErr) throw sErr;

    // Traer TODAS las fichas en lotes
    const todasFichas = [];
    let desde = 0;
    const LOTE = 1000;
    while (true) {
      const { data: lote, error: lErr } = await supabase
        .from('fichas_tienda').select('id, tienda_id, semana_id, desbloqueado')
        .range(desde, desde + LOTE - 1);
      if (lErr) throw lErr;
      if (!lote || lote.length === 0) break;
      todasFichas.push(...lote);
      if (lote.length < LOTE) break;
      desde += LOTE;
    }

    // Agrupar fichas por tienda
    const fichasPorTienda = {};
    for (const f of todasFichas) {
      if (!fichasPorTienda[f.tienda_id]) fichasPorTienda[f.tienda_id] = [];
      fichasPorTienda[f.tienda_id].push(f);
    }

    const discrepancias = [];
    const corregidas = [];

    for (const tienda of (tiendas || [])) {
      const hc = tienda.total_empleados || 0;
      const dist = calcularDistribucion(hc);
      const totalEsperado = dist.reduce((a, b) => a + b, 0);
      const fichas = fichasPorTienda[tienda.id] || [];
      const totalActual = fichas.length;

      if (totalActual !== totalEsperado) {
        const item = {
          id: tienda.id,
          codigo: tienda.codigo,
          nombre: tienda.nombre,
          hc,
          fichas_esperadas: totalEsperado,
          fichas_actuales: totalActual,
          diferencia: totalEsperado - totalActual,
        };
        discrepancias.push(item);

        if (!soloReportar) {
          let fichasAgregadas = 0, fichasEliminadas = 0;
          for (const semana of (semanas || [])) {
            const fichasSemana = dist[semana.numero - 1] ?? 0;
            const fichasExist = fichas.filter(f => f.semana_id === semana.id);
            const totalExist = fichasExist.length;
            const diff = fichasSemana - totalExist;
            if (diff > 0) {
              const nuevas = Array.from({ length: diff }, (_, i) => ({
                tienda_id: tienda.id, semana_id: semana.id,
                numero_ficha: totalExist + i + 1, desbloqueado: false,
              }));
              await supabase.from('fichas_tienda').insert(nuevas);
              fichasAgregadas += diff;
            } else if (diff < 0) {
              const bloqueadas = fichasExist.filter(f => !f.desbloqueado);
              const aEliminar = Math.min(-diff, bloqueadas.length);
              if (aEliminar > 0) {
                const ids = bloqueadas.slice(-aEliminar).map(f => f.id);
                await supabase.from('fichas_tienda').delete().in('id', ids);
                fichasEliminadas += aEliminar;
              }
            }
          }
          corregidas.push({ ...item, fichas_agregadas: fichasAgregadas, fichas_eliminadas: fichasEliminadas });
        }
      }
    }

    res.json({
      ok: true,
      solo_reporte: soloReportar,
      total_tiendas: (tiendas || []).length,
      total_discrepancias: discrepancias.length,
      tiendas: soloReportar ? discrepancias : corregidas,
    });
  } catch (err) {
    console.error('[Recalcular Todas]', err.message);
    res.status(500).json({ error: 'Error: ' + err.message });
  }
});

// POST /api/tiendas/:id/recalcular-fichas — admin: recalcula fichas sin tocar desbloqueadas
router.post('/:id/recalcular-fichas', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') {
    return res.status(403).json({ error: 'No eres administrador.' });
  }

  const tiendaId = req.params.id;
  const nuevoHC = req.body.total_empleados != null ? parseInt(req.body.total_empleados) : null;

  try {
    const { data: tienda, error: tErr } = await supabase
      .from('tiendas')
      .select('id, codigo, nombre, total_empleados')
      .eq('id', tiendaId)
      .maybeSingle();

    if (tErr || !tienda) return res.status(404).json({ error: 'Tienda no encontrada.' });

    const hc = nuevoHC != null && !isNaN(nuevoHC) ? nuevoHC : tienda.total_empleados;

    if (nuevoHC != null && !isNaN(nuevoHC) && nuevoHC !== tienda.total_empleados) {
      await supabase.from('tiendas').update({ total_empleados: hc }).eq('id', tiendaId);
    }

    const dist = calcularDistribucion(hc);

    const { data: semanas } = await supabase
      .from('semanas').select('id, numero').order('numero');

    let fichasAgregadas = 0, fichasEliminadas = 0;

    for (const semana of (semanas || [])) {
      const fichasSemana = dist[semana.numero - 1] ?? 0;

      const { data: fichasExist } = await supabase
        .from('fichas_tienda')
        .select('id, desbloqueado')
        .eq('tienda_id', tiendaId)
        .eq('semana_id', semana.id);

      const existentes = fichasExist || [];
      const totalExist = existentes.length;
      const diff = fichasSemana - totalExist;

      if (diff > 0) {
        const nuevas = Array.from({ length: diff }, (_, i) => ({
          tienda_id: tiendaId,
          semana_id: semana.id,
          numero_ficha: totalExist + i + 1,
          desbloqueado: false,
        }));
        await supabase.from('fichas_tienda').insert(nuevas);
        fichasAgregadas += diff;
      } else if (diff < 0) {
        const bloqueadas = existentes.filter(f => !f.desbloqueado);
        const aEliminar = Math.min(-diff, bloqueadas.length);
        if (aEliminar > 0) {
          const ids = bloqueadas.slice(-aEliminar).map(f => f.id);
          await supabase.from('fichas_tienda').delete().in('id', ids);
          fichasEliminadas += aEliminar;
        }
      }
    }

    res.json({
      ok: true,
      tienda: tienda.nombre,
      hc_nuevo: hc,
      distribucion_semanal: dist,
      fichas_total: dist.reduce((a, b) => a + b, 0),
      fichas_agregadas: fichasAgregadas,
      fichas_eliminadas: fichasEliminadas,
    });

  } catch (err) {
    console.error('[Recalcular Fichas]', err.message);
    res.status(500).json({ error: 'Error al recalcular fichas: ' + err.message });
  }
});

// POST /api/tiendas/:id/reset-password — admin: restablece contraseña a sport123
router.post('/:id/reset-password', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'No eres administrador.' });

  const { data: tienda, error: tErr } = await supabase
    .from('tiendas').select('id, nombre').eq('id', req.params.id).maybeSingle();

  if (tErr || !tienda) return res.status(404).json({ error: 'Tienda no encontrada.' });

  const { error } = await supabase.from('tiendas')
    .update({ password_hash: 'sport123', password_changed_at: null })
    .eq('id', req.params.id);

  if (error) return res.status(500).json({ error: error.message });

  res.json({ ok: true, tienda: tienda.nombre, mensaje: 'Contraseña restablecida a sport123.' });
});

module.exports = router;
