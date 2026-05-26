const router = require('express').Router();
const { verificarToken } = require('./auth');
const db  = require('../db');
const gcs = require('../gcs');

// GET /api/album — Fichas de la tienda agrupadas por semana
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });

  try {
    const tiendaId = req.usuario.id;

    const [semanaActiva, semanas, fichas, resultados] = await Promise.all([
      db.one('SELECT id, numero, nombre FROM semanas WHERE activa = true LIMIT 1'),
      db.all('SELECT id, numero, nombre FROM semanas ORDER BY numero'),
      db.all(
        `SELECT id, semana_id, numero_ficha, desbloqueado, foto_url
         FROM fichas_tienda WHERE tienda_id = $1 ORDER BY semana_id, numero_ficha`,
        [tiendaId]
      ),
      db.all(
        'SELECT semana_id, porcentaje_cumplido FROM resultados_tienda WHERE tienda_id = $1',
        [tiendaId]
      ),
    ]);

    const semanaMap    = Object.fromEntries(semanas.map(s => [s.id, s]));
    const resultadoMap = Object.fromEntries(resultados.map(r => [r.semana_id, r.porcentaje_cumplido]));
    const pctTienda    = semanaActiva ? (resultadoMap[semanaActiva.id] ?? null) : null;

    let contador = 1;
    const fichasConInfo = fichas.map(f => {
      const sem = semanaMap[f.semana_id] || {};
      return {
        id:             f.id,
        numero:         contador++,
        semana_id:      f.semana_id,
        semana_numero:  sem.numero  || null,
        semana_nombre:  sem.nombre  || null,
        numero_ficha:   f.numero_ficha,
        desbloqueado:   f.desbloqueado,
        foto_url:       f.foto_url || null,
        porcentaje:     resultadoMap[f.semana_id] ?? null,
      };
    });

    res.json({
      fichas:           fichasConInfo,
      semana:           semanaActiva || null,
      porcentaje_tienda: pctTienda,
      total:            fichasConInfo.length,
      desbloqueadas:    fichasConInfo.filter(f => f.desbloqueado).length,
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

    const [semanas, fichas, resultados] = await Promise.all([
      db.all('SELECT id, numero, nombre FROM semanas ORDER BY numero'),
      db.all(
        'SELECT semana_id, desbloqueado, foto_url FROM fichas_tienda WHERE tienda_id = $1',
        [tiendaId]
      ),
      db.all(
        'SELECT semana_id, porcentaje_cumplido FROM resultados_tienda WHERE tienda_id = $1',
        [tiendaId]
      ),
    ]);

    const semanaMap    = Object.fromEntries(semanas.map(s => [s.id, s]));
    const resultadoMap = Object.fromEntries(resultados.map(r => [r.semana_id, r.porcentaje_cumplido]));

    const porSemana = {};
    for (const f of fichas) {
      const sem = semanaMap[f.semana_id];
      if (!sem) continue;
      if (!porSemana[sem.numero]) {
        porSemana[sem.numero] = {
          semana_numero: sem.numero,
          semana_nombre: sem.nombre,
          porcentaje:    resultadoMap[f.semana_id] ?? null,
          total: 0, desbloqueadas: 0, con_foto: 0,
        };
      }
      porSemana[sem.numero].total++;
      if (f.desbloqueado) porSemana[sem.numero].desbloqueadas++;
      if (f.foto_url)     porSemana[sem.numero].con_foto++;
    }

    res.json({ semanas: Object.values(porSemana).sort((a, b) => a.semana_numero - b.semana_numero) });
  } catch (err) {
    console.error('[Album Admin]', err.message);
    res.status(500).json({ error: 'Error al cargar fichas.' });
  }
});

// POST /api/album/foto — subir foto a una ficha desbloqueada (Cloud Storage)
router.post('/foto', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  const { ficha_id, foto_base64, tipo } = req.body;
  if (!ficha_id || !foto_base64) return res.status(400).json({ error: 'Datos incompletos.' });

  try {
    const ficha = await db.one(
      'SELECT id, tienda_id, desbloqueado FROM fichas_tienda WHERE id = $1',
      [ficha_id]
    );

    if (!ficha || ficha.tienda_id !== req.usuario.id)
      return res.status(403).json({ error: 'Sin permiso sobre esta ficha.' });
    if (!ficha.desbloqueado)
      return res.status(403).json({ error: 'Esta ficha no está desbloqueada.' });

    const ext      = (tipo || '').includes('png') ? 'png' : 'jpg';
    const filename = `ficha-${ficha_id}.${ext}`;
    const fotoUrl  = await gcs.uploadBase64(filename, foto_base64, tipo || 'image/jpeg');

    await db.query('UPDATE fichas_tienda SET foto_url = $1 WHERE id = $2', [fotoUrl, ficha_id]);

    res.json({ ok: true, foto_url: fotoUrl });
  } catch (err) {
    console.error('[Foto]', err.message);
    res.status(500).json({ error: 'Error al subir foto: ' + err.message });
  }
});

module.exports = router;
