const router = require('express').Router();
const { verificarToken } = require('./auth');
const db = require('../db');

// GET /api/notificaciones/pendientes — tiendas con empleados al 100% en la semana activa
router.get('/pendientes', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Solo para admin.' });
  try {
    const semana = await db.one('SELECT id, numero, nombre FROM semanas WHERE activa = true LIMIT 1');
    if (!semana) return res.json({ tiendas: [], semana: null });

    const rows = await db.all(
      `SELECT e.id AS emp_id, e.nombre AS emp_nombre, e.cargo, e.tienda_id,
              t.nombre AS tienda_nombre, t.email AS tienda_email
       FROM resultados_ventas rv
       JOIN empleados e ON e.id = rv.empleado_id
       JOIN tiendas   t ON t.id = e.tienda_id
       WHERE rv.semana_id = $1 AND rv.cumplio_meta = true`,
      [semana.id]
    );

    if (!rows.length) return res.json({ tiendas: [], semana });

    const porTienda = {};
    for (const r of rows) {
      if (!porTienda[r.tienda_id]) {
        porTienda[r.tienda_id] = {
          tienda_id: r.tienda_id,
          nombre:    r.tienda_nombre,
          email:     r.tienda_email || '',
          empleados: [],
        };
      }
      porTienda[r.tienda_id].empleados.push({ nombre: r.emp_nombre, cargo: r.cargo });
    }

    res.json({ tiendas: Object.values(porTienda), semana });
  } catch (err) {
    console.error('[Notif pendientes]', err.message);
    res.status(500).json({ error: 'Error al obtener pendientes.' });
  }
});

// POST /api/notificaciones/enviar/:tienda_id — admin envía email de notificación a una tienda
router.post('/enviar/:tienda_id', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Solo para admin.' });
  const { empleados, semana_nombre } = req.body;
  try {
    const tienda = await db.one('SELECT nombre, email FROM tiendas WHERE id = $1', [req.params.tienda_id]);
    if (!tienda?.email) return res.status(404).json({ error: 'Tienda sin email registrado.' });

    const destinatario = process.env.NOTIFY_OVERRIDE_EMAIL || tienda.email;
    const apiKey = process.env.BREVO_API_KEY || process.env.RESEND_API_KEY;
    if (!apiKey) {
      return res.status(503).json({ error: 'Servicio de email no configurado. Agrega BREVO_API_KEY.' });
    }

    const frontendUrl = process.env.FRONTEND_URL || 'https://TU_PROYECTO.web.app';
    const total = empleados?.length || 0;

    const filas = [];
    const lista = empleados || [];
    for (let i = 0; i < lista.length; i += 3) {
      const grupo = lista.slice(i, i + 3);
      while (grupo.length < 3) grupo.push(null);
      filas.push(`<tr>${grupo.map(e => e
        ? `<td width="33%" style="padding:7px;vertical-align:top;">
            <table width="100%" cellpadding="0" cellspacing="0" style="border-radius:12px;overflow:hidden;border:1.5px solid rgba(247,168,0,.45);">
              <tr><td style="background:linear-gradient(90deg,#b86e00,#F7A800,#b86e00);height:4px;font-size:0;">&nbsp;</td></tr>
              <tr><td style="background:linear-gradient(180deg,#0d1f6e,#060f3a);padding:14px 10px 10px;text-align:center;">
                <div style="font-size:26px;line-height:1;margin-bottom:8px;">⭐</div>
                <div style="background:rgba(247,168,0,.2);border:1px solid rgba(247,168,0,.4);color:#F7A800;font-size:9px;letter-spacing:.1em;padding:3px 8px;border-radius:20px;display:inline-block;font-weight:bold;">✓ &nbsp;100%</div>
              </td></tr>
              <tr><td style="background:#02061a;padding:10px;text-align:center;border-top:1px solid rgba(247,168,0,.15);">
                <div style="color:#ffffff;font-size:11px;font-weight:bold;line-height:1.4;">${e.nombre}</div>
                <div style="color:rgba(255,255,255,.4);font-size:9px;margin-top:3px;">${e.cargo || 'Asesor de Ventas'}</div>
              </td></tr>
            </table>
           </td>`
        : `<td width="33%" style="padding:7px;"></td>`).join('')}</tr>`);
    }

    const htmlBody = `<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><title>Álbum Estrellas · SLA Corp.</title></head>
<body style="margin:0;padding:20px 0;background:#0a0e2e;font-family:'Segoe UI',Arial,sans-serif;">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#0a0e2e;">
<tr><td align="center" style="padding:0 10px;">
  <table width="580" cellpadding="0" cellspacing="0" style="max-width:580px;width:100%;">
    <tr><td style="background:linear-gradient(160deg,#0d1340,#0a2272 50%,#0046AD);border-radius:18px 18px 0 0;padding:36px 30px 28px;text-align:center;">
      <div style="color:#ffffff;font-size:34px;font-weight:900;letter-spacing:.08em;">ÁLBUM <span style="color:#F7A800;">ESTRELLAS</span></div>
      <div style="color:rgba(255,255,255,.45);font-size:11px;letter-spacing:.14em;margin-top:8px;">SLA CORP. · TEMPORADA MUNDIAL 2026</div>
    </td></tr>
    <tr><td style="background:linear-gradient(90deg,#c87800,#F7A800,#c87800);height:4px;font-size:0;">&nbsp;</td></tr>
    <tr><td style="background:linear-gradient(135deg,#001a55,#0035a0);padding:24px 30px;text-align:center;">
      <div style="color:#F7A800;font-size:24px;font-weight:900;">¡META ALCANZADA!</div>
      <div style="display:inline-block;background:rgba(255,255,255,.1);border-radius:20px;padding:6px 20px;margin-top:10px;">
        <span style="color:rgba(255,255,255,.9);font-size:13px;font-weight:bold;">${tienda.nombre}</span>
        <span style="color:rgba(255,255,255,.4);"> · </span>
        <span style="color:rgba(255,255,255,.7);font-size:13px;">${semana_nombre}</span>
      </div>
    </td></tr>
    <tr><td style="background:#050c2e;padding:28px 34px 20px;">
      <p style="color:rgba(255,255,255,.85);line-height:1.75;margin:0;font-size:14.5px;">
        ¡Excelentes noticias! ${total === 1 ? 'Un asesor de tu equipo alcanzó' : `<strong style="color:#F7A800;">${total} asesores</strong> de tu equipo alcanzaron`}
        el <strong style="color:#F7A800;">100% de su meta de ventas</strong> esta semana. Su espacio en el <strong style="color:#fff;">Álbum Estrellas</strong> está desbloqueado. 📸
      </p>
    </td></tr>
    <tr><td style="background:#050c2e;padding:12px 20px 28px;">
      <table width="100%" cellpadding="0" cellspacing="0">${filas.join('')}</table>
    </td></tr>
    <tr><td style="background:#050c2e;padding:0 30px 36px;text-align:center;">
      <a href="${frontendUrl}/album.html" style="display:inline-block;padding:15px 44px;background:linear-gradient(135deg,#F7A800,#d98c00);color:#000;text-decoration:none;border-radius:50px;font-weight:900;font-size:15px;">
        📷 &nbsp;Ir al Álbum y Subir Foto
      </a>
    </td></tr>
    <tr><td style="background:#02061a;border-radius:0 0 18px 18px;border-top:1.5px solid rgba(247,168,0,.25);padding:18px 30px;text-align:center;">
      <p style="color:rgba(255,255,255,.2);font-size:10px;margin:0;">SLA CORP. · Correo automático — no responder.</p>
    </td></tr>
  </table>
</td></tr></table>
</body></html>`;

    const respEmail = await fetch('https://api.brevo.com/v3/smtp/email', {
      method:  'POST',
      headers: { 'api-key': apiKey, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        sender:      { name: 'Álbum Estrellas · SLA Corp.', email: process.env.BREVO_SENDER || 'conectados@sportline.com.pa' },
        to:          [{ email: destinatario }],
        subject:     `⭐ ${total} asesor${total !== 1 ? 'es' : ''} desbloquearon su figurita — ${semana_nombre}`,
        htmlContent: htmlBody,
      }),
    });

    if (!respEmail.ok) {
      const errData = await respEmail.json();
      throw new Error(errData.message || 'Error de Brevo');
    }

    res.json({ ok: true, email: destinatario });
  } catch (err) {
    console.error('[Email enviar]', err.message);
    res.status(500).json({ error: `Error al enviar: ${err.message}` });
  }
});

module.exports = router;
