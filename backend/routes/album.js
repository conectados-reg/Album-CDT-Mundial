const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function verificarToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token faltante.' });
  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Sesión inválida.' });
  }
}

// GET /api/album — Fichas de la tienda agrupadas por semana
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });

  try {
    const tiendaId = req.usuario.id;

    const { data: tiendaInfo } = await supabase
      .from('tiendas').select('total_empleados').eq('id', tiendaId).maybeSingle();

    const { data: semanaActivaDB } = await supabase
      .from('semanas').select('id, numero, nombre').eq('activa', true).maybeSingle();

    const { data: semanas } = await supabase
      .from('semanas').select('id, numero, nombre').order('numero');
    const semanaMap = {};
    for (const s of (semanas || [])) semanaMap[s.id] = s;

    const { data: fichas, error } = await supabase
      .from('fichas_tienda')
      .select('id, semana_id, numero_ficha, desbloqueado, foto_url')
      .eq('tienda_id', tiendaId)
      .order('semana_id')
      .order('numero_ficha');

    if (error) throw error;

    const { data: resultados } = await supabase
      .from('resultados_tienda')
      .select('semana_id, porcentaje_cumplido')
      .eq('tienda_id', tiendaId);
    const resultadoMap = {};
    for (const r of (resultados || [])) resultadoMap[r.semana_id] = r.porcentaje_cumplido;

    // Use explicitly active semana; fall back to latest semana with non-zero results
    let semanaActiva = semanaActivaDB;
    if (!semanaActiva && resultados && resultados.length > 0) {
      let best = null;
      for (const r of resultados) {
        if (r.porcentaje_cumplido > 0) {
          const s = semanaMap[r.semana_id];
          if (s && (!best || s.numero > best.numero)) best = s;
        }
      }
      semanaActiva = best || null;
    }

    const pctTienda = semanaActiva ? (resultadoMap[semanaActiva.id] ?? null) : null;

    let contador = 1;
    const fichasConInfo = (fichas || []).map(f => {
      const sem = semanaMap[f.semana_id] || {};
      return {
        id: f.id,
        numero: contador++,
        semana_id: f.semana_id,
        semana_numero: sem.numero || null,
        semana_nombre: sem.nombre || null,
        numero_ficha: f.numero_ficha,
        desbloqueado: f.desbloqueado,
        foto_url: f.foto_url || null,
        porcentaje: resultadoMap[f.semana_id] ?? null,
      };
    });

    res.json({
      fichas: fichasConInfo,
      semana: semanaActiva || null,
      porcentaje_tienda: pctTienda,
      hc: tiendaInfo?.total_empleados ?? null,
      total: fichasConInfo.length,
      desbloqueadas: fichasConInfo.filter(f => f.desbloqueado).length,
    });

  } catch (err) {
    console.error('[Album]', err.message);
    res.status(500).json({ error: 'Error al cargar el álbum.' });
  }
});

// GET /api/album/admin/:tienda_id — admin: resumen de fichas por semana
router.get('/admin/:tienda_id', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Solo para administradores.' });

  try {
    const tiendaId = req.params.tienda_id;

    const { data: semanas } = await supabase
      .from('semanas').select('id, numero, nombre').order('numero');
    const semanaMap = {};
    for (const s of (semanas || [])) semanaMap[s.id] = s;

    const { data: fichas } = await supabase
      .from('fichas_tienda')
      .select('semana_id, desbloqueado, foto_url')
      .eq('tienda_id', tiendaId);

    const { data: resultados } = await supabase
      .from('resultados_tienda')
      .select('semana_id, porcentaje_cumplido')
      .eq('tienda_id', tiendaId);
    const resultadoMap = {};
    for (const r of (resultados || [])) resultadoMap[r.semana_id] = r.porcentaje_cumplido;

    const porSemana = {};
    for (const f of (fichas || [])) {
      const sem = semanaMap[f.semana_id];
      if (!sem) continue;
      if (!porSemana[sem.numero]) {
        porSemana[sem.numero] = {
          semana_numero: sem.numero,
          semana_nombre: sem.nombre,
          porcentaje: resultadoMap[f.semana_id] ?? null,
          total: 0, desbloqueadas: 0, con_foto: 0,
        };
      }
      porSemana[sem.numero].total++;
      if (f.desbloqueado) porSemana[sem.numero].desbloqueadas++;
      if (f.foto_url) porSemana[sem.numero].con_foto++;
    }

    res.json({ semanas: Object.values(porSemana).sort((a, b) => a.semana_numero - b.semana_numero) });
  } catch (err) {
    console.error('[Album Admin]', err.message);
    res.status(500).json({ error: 'Error al cargar fichas.' });
  }
});

// GET /api/album/simulacro/:tienda_id — fichas completas con IDs para el simulacro
router.get('/simulacro/:tienda_id', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Solo para administradores.' });
  try {
    const { data: semanas } = await supabase.from('semanas').select('id, numero, nombre').order('numero');
    const semanaMap = {};
    for (const s of (semanas || [])) semanaMap[s.id] = s;

    const { data: fichas } = await supabase.from('fichas_tienda')
      .select('id, semana_id, numero_ficha, desbloqueado, foto_url')
      .eq('tienda_id', req.params.tienda_id)
      .order('semana_id').order('numero_ficha');

    const fichasConInfo = (fichas || []).map(f => ({
      id: f.id,
      semana_id: f.semana_id,
      semana_numero: (semanaMap[f.semana_id] || {}).numero || null,
      semana_nombre: (semanaMap[f.semana_id] || {}).nombre || null,
      numero_ficha: f.numero_ficha,
      desbloqueado: f.desbloqueado,
      foto_url: f.foto_url || null,
    }));
    res.json({ fichas: fichasConInfo });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/album/simulacro/toggle — desbloquea o bloquea fichas de una semana para una tienda
router.post('/simulacro/toggle', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Solo para administradores.' });
  const { tienda_id, semana_numero, desbloquear } = req.body;
  if (!tienda_id || semana_numero == null) return res.status(400).json({ error: 'Faltan campos.' });
  try {
    const { data: semana } = await supabase.from('semanas').select('id').eq('numero', semana_numero).maybeSingle();
    if (!semana) return res.status(404).json({ error: 'Semana no encontrada.' });

    const update = desbloquear
      ? { desbloqueado: true }
      : { desbloqueado: false, foto_url: null };

    await supabase.from('fichas_tienda').update(update)
      .eq('tienda_id', tienda_id).eq('semana_id', semana.id);

    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/album/simulacro/foto — admin sube foto a cualquier ficha
router.post('/simulacro/foto', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Solo para administradores.' });
  const { ficha_id, foto_base64, tipo } = req.body;
  if (!ficha_id || !foto_base64) return res.status(400).json({ error: 'Datos incompletos.' });
  try {
    const { data: ficha } = await supabase.from('fichas_tienda').select('id, desbloqueado').eq('id', ficha_id).single();
    if (!ficha) return res.status(404).json({ error: 'Ficha no encontrada.' });
    if (!ficha.desbloqueado) return res.status(403).json({ error: 'Ficha no desbloqueada.' });

    const buffer = Buffer.from(foto_base64, 'base64');
    const ext = (tipo || '').includes('png') ? 'png' : 'jpg';
    const filename = `ficha-${ficha_id}.${ext}`;

    const { error: uploadError } = await supabase.storage
      .from('fotos-empleados').upload(filename, buffer, { contentType: tipo || 'image/jpeg', upsert: true });
    if (uploadError) throw uploadError;

    const { data: urlData } = supabase.storage.from('fotos-empleados').getPublicUrl(filename);
    await supabase.from('fichas_tienda').update({ foto_url: urlData.publicUrl }).eq('id', ficha_id);

    res.json({ ok: true, foto_url: urlData.publicUrl });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/album/libro — admin: todas las fotos de todas las tiendas para el libro conmemorativo
router.get('/libro', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Solo para administradores.' });
  try {
    const [
      { data: tiendas, error: tErr },
      { data: fichas, error: fErr },
      { data: semanas, error: sErr },
    ] = await Promise.all([
      supabase.from('tiendas').select('id, codigo, nombre, region, total_empleados').eq('activa', true).order('region').order('nombre'),
      supabase.from('fichas_tienda').select('id, tienda_id, semana_id, numero_ficha, foto_url').not('foto_url', 'is', null).order('tienda_id').order('semana_id'),
      supabase.from('semanas').select('id, numero, nombre').order('numero'),
    ]);
    if (tErr) throw tErr;
    if (fErr) throw fErr;
    if (sErr) throw sErr;

    const semanaMap = {};
    for (const s of (semanas || [])) semanaMap[s.id] = s;

    const fichasByTienda = {};
    for (const f of (fichas || [])) {
      if (!fichasByTienda[f.tienda_id]) fichasByTienda[f.tienda_id] = [];
      fichasByTienda[f.tienda_id].push({
        foto_url: f.foto_url,
        semana_numero: (semanaMap[f.semana_id] || {}).numero || null,
        semana_nombre: (semanaMap[f.semana_id] || {}).nombre || null,
        numero_ficha: f.numero_ficha,
      });
    }

    const resultado = (tiendas || [])
      .filter(t => fichasByTienda[t.id]?.length > 0)
      .map(t => ({
        id: t.id,
        codigo: t.codigo,
        nombre: t.nombre,
        region: t.region || 'General',
        total_empleados: t.total_empleados || 0,
        fotos: fichasByTienda[t.id] || [],
      }));

    const totalFotos = resultado.reduce((sum, t) => sum + t.fotos.length, 0);

    res.json({
      tiendas: resultado,
      total_tiendas: resultado.length,
      total_fotos: totalFotos,
    });
  } catch (err) {
    console.error('[Album Libro]', err.message);
    res.status(500).json({ error: 'Error al cargar el libro.' });
  }
});

// GET /api/album/libro-publico?pais=gt — página pública compartible, sin login, solo un país
const ISO_MAP_PAISES = [
  ['costa rica', 'cr'], ['el salvador', 'sv'], ['guatemala', 'gt'],
  ['honduras', 'hn'], ['nicaragua', 'ni'], ['panama', 'pa'], ['panamá', 'pa'],
  ['domini', 'do'], ['repúbli', 'do'], ['urugu', 'uy'], ['colombia', 'co'],
];
function isoDeRegion(region) {
  const r = (region || '').toLowerCase().trim();
  for (const [nombre, codigo] of ISO_MAP_PAISES) {
    if (r.indexOf(nombre) !== -1) return codigo;
  }
  return null;
}

router.get('/libro-publico', async (req, res) => {
  const pais = (req.query.pais || '').toLowerCase().trim();
  if (!pais) return res.status(400).json({ error: 'Falta el parámetro pais.' });

  try {
    const { data: tiendas, error: tErr } = await supabase
      .from('tiendas').select('id, codigo, nombre, region, total_empleados').eq('activa', true);
    if (tErr) throw tErr;

    const tiendasPais = (tiendas || []).filter(t => isoDeRegion(t.region) === pais);
    if (tiendasPais.length === 0) return res.status(404).json({ error: 'País no encontrado.' });

    const ids = tiendasPais.map(t => t.id);
    const [{ data: fichas, error: fErr }, { data: semanas, error: sErr }] = await Promise.all([
      supabase.from('fichas_tienda').select('id, tienda_id, semana_id, numero_ficha, foto_url')
        .in('tienda_id', ids).not('foto_url', 'is', null),
      supabase.from('semanas').select('id, numero, nombre'),
    ]);
    if (fErr) throw fErr;
    if (sErr) throw sErr;

    const semanaMap = {};
    for (const s of (semanas || [])) semanaMap[s.id] = s;

    const fichasByTienda = {};
    for (const f of (fichas || [])) {
      if (!fichasByTienda[f.tienda_id]) fichasByTienda[f.tienda_id] = [];
      fichasByTienda[f.tienda_id].push({
        foto_url: f.foto_url,
        semana_numero: (semanaMap[f.semana_id] || {}).numero || null,
        semana_nombre: (semanaMap[f.semana_id] || {}).nombre || null,
        numero_ficha: f.numero_ficha,
      });
    }

    const resultado = tiendasPais
      .filter(t => fichasByTienda[t.id]?.length > 0)
      .map(t => ({
        id: t.id,
        codigo: t.codigo,
        nombre: t.nombre,
        region: t.region || 'General',
        total_empleados: t.total_empleados || 0,
        fotos: fichasByTienda[t.id] || [],
      }));

    const totalFotos = resultado.reduce((sum, t) => sum + t.fotos.length, 0);

    res.json({
      tiendas: resultado,
      total_tiendas: resultado.length,
      total_fotos: totalFotos,
      region: tiendasPais[0].region || null,
    });
  } catch (err) {
    console.error('[Album Libro Publico]', err.message);
    res.status(500).json({ error: 'Error al cargar el álbum del país.' });
  }
});

// POST /api/album/foto — subir foto a una ficha desbloqueada
router.post('/foto', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  const { ficha_id, foto_base64, tipo } = req.body;
  if (!ficha_id || !foto_base64) return res.status(400).json({ error: 'Datos incompletos.' });

  try {
    const { data: ficha } = await supabase
      .from('fichas_tienda').select('id, tienda_id, desbloqueado').eq('id', ficha_id).single();

    if (!ficha || ficha.tienda_id !== req.usuario.id)
      return res.status(403).json({ error: 'Sin permiso sobre esta ficha.' });
    if (!ficha.desbloqueado)
      return res.status(403).json({ error: 'Esta ficha no está desbloqueada.' });

    const buffer = Buffer.from(foto_base64, 'base64');
    const ext = (tipo || '').includes('png') ? 'png' : 'jpg';
    const filename = `ficha-${ficha_id}.${ext}`;

    const { error: uploadError } = await supabase.storage
      .from('fotos-empleados')
      .upload(filename, buffer, { contentType: tipo || 'image/jpeg', upsert: true });
    if (uploadError) throw uploadError;

    const { data: urlData } = supabase.storage.from('fotos-empleados').getPublicUrl(filename);
    const fotoUrl = urlData.publicUrl;

    await supabase.from('fichas_tienda').update({ foto_url: fotoUrl }).eq('id', ficha_id);

    res.json({ ok: true, foto_url: fotoUrl });
  } catch (err) {
    console.error('[Foto]', err.message);
    res.status(500).json({ error: 'Error al subir foto: ' + err.message });
  }
});

module.exports = router;
