const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function verificarToken(req, res, next) {
  const token = req.cookies?.token || req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token faltante.' });
  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Sesión inválida.' });
  }
}

// GET /api/notificaciones/pendientes — tiendas con empleados al 100% en la semana activa
router.get('/pendientes', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Solo para admin.' });
  try {
    const { data: semana } = await supabase
      .from('semanas').select('id, numero, nombre').eq('activa', true).single();
    if (!semana) return res.json({ tiendas: [], semana: null });

    const { data: resultados, error: rErr } = await supabase
      .from('resultados_ventas')
      .select('empleado_id')
      .eq('semana_id', semana.id)
      .eq('cumplio_meta', true);
    if (rErr) throw rErr;
    if (!resultados?.length) return res.json({ tiendas: [], semana });

    const empIds = resultados.map(r => r.empleado_id);
    const { data: empleados, error: eErr } = await supabase
      .from('empleados').select('id, nombre, cargo, tienda_id').in('id', empIds);
    if (eErr) throw eErr;

    const tiendaIds = [...new Set((empleados || []).map(e => e.tienda_id))];
    const { data: tiendas, error: tErr } = await supabase
      .from('tiendas').select('id, nombre, email').in('id', tiendaIds);
    if (tErr) throw tErr;

    const tiendaMap = {};
    for (const t of (tiendas || [])) tiendaMap[t.id] = t;
    const empMap = {};
    for (const e of (empleados || [])) empMap[e.id] = e;

    const porTienda = {};
    for (const r of resultados) {
      const emp = empMap[r.empleado_id];
      if (!emp) continue;
      const t = tiendaMap[emp.tienda_id];
      if (!t) continue;
      if (!porTienda[t.id]) {
        porTienda[t.id] = { tienda_id: t.id, nombre: t.nombre, email: t.email || '', empleados: [] };
      }
      porTienda[t.id].empleados.push({ nombre: emp.nombre, cargo: emp.cargo });
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
  const { empleados, semana_nombre, semana_numero } = req.body;
  try {
    const { data: tienda } = await supabase
      .from('tiendas').select('nombre, email').eq('id', req.params.tienda_id).single();
    if (!tienda?.email) return res.status(404).json({ error: 'Tienda sin email registrado.' });

    const destinatario = process.env.NOTIFY_OVERRIDE_EMAIL || tienda.email;

    const apiKey = process.env.BREVO_API_KEY || process.env.RESEND_API_KEY;
    if (!apiKey) {
      return res.status(503).json({ error: 'Servicio de email no configurado. Agrega BREVO_API_KEY en Render.' });
    }

    const frontendUrl = process.env.FRONTEND_URL || 'https://album-cdt-mundial.onrender.com';
    const total = empleados?.length || 0;

    const tarjetas = (empleados || []).map((e, i) => `
      <td width="30%" style="padding:0 6px;vertical-align:top;text-align:center;">
        <table width="100%" cellpadding="0" cellspacing="0" style="background:linear-gradient(180deg,#001a55,#000d2e);border-radius:10px;overflow:hidden;border:1.5px solid rgba(247,168,0,0.5);">
          <tr><td style="background:linear-gradient(90deg,#F7A800,#e69500);height:5px;font-size:0;">&nbsp;</td></tr>
          <tr><td style="padding:14px 8px 6px;text-align:center;">
            <div style="font-size:2.2em;line-height:1;">⭐</div>
            <div style="background:rgba(247,168,0,.15);color:#F7A800;font-size:9px;letter-spacing:.12em;padding:2px 6px;border-radius:10px;margin:6px auto 8px;display:inline-block;font-weight:bold;">AL 100%</div>
          </td></tr>
          <tr><td style="background:rgba(0,0,0,.3);padding:8px;border-top:1px solid rgba(255,255,255,.07);">
            <div style="color:#fff;font-size:10px;font-weight:bold;letter-spacing:.04em;line-height:1.3;">${e.nombre}</div>
            <div style="color:rgba(255,255,255,.45);font-size:9px;margin-top:3px;">${e.cargo || 'Asesor de Ventas'}</div>
          </td></tr>
        </table>
      </td>`).join('');

    const filas = [];
    const lista = empleados || [];
    for (let i = 0; i < lista.length; i += 3) {
      const grupo = lista.slice(i, i + 3);
      while (grupo.length < 3) grupo.push(null);
      filas.push(`<tr>${grupo.map((e) => e
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
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Álbum Estrellas · SLA Corp.</title></head>
<body style="margin:0;padding:20px 0;background:#0a0e2e;font-family:'Segoe UI',Arial,Helvetica,sans-serif;">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#0a0e2e;">
<tr><td align="center" style="padding:0 10px;">
  <table width="580" cellpadding="0" cellspacing="0" style="max-width:580px;width:100%;">

    <!-- HEADER -->
    <tr><td style="background:linear-gradient(160deg,#0d1340 0%,#0a2272 50%,#0046AD 100%);border-radius:18px 18px 0 0;padding:36px 30px 28px;text-align:center;">
      <div style="margin-bottom:16px;">
        <span style="display:inline-block;background:rgba(247,168,0,.18);border:1.5px solid rgba(247,168,0,.5);border-radius:30px;padding:6px 18px;color:#F7A800;font-size:11px;letter-spacing:.18em;font-weight:bold;text-transform:uppercase;">⚽ &nbsp;FIFA MUNDIAL 2026</span>
      </div>
      <div style="color:#ffffff;font-size:34px;font-weight:900;letter-spacing:.08em;line-height:1;margin-bottom:6px;">
        ÁLBUM <span style="color:#F7A800;">ESTRELLAS</span>
      </div>
      <div style="color:rgba(255,255,255,.45);font-size:11px;letter-spacing:.14em;margin-top:8px;">SLA CORP. &nbsp;·&nbsp; TEMPORADA MUNDIAL 2026</div>
    </td></tr>

    <!-- BANDA DORADA -->
    <tr><td style="background:linear-gradient(90deg,#c87800,#F7A800,#c87800);height:4px;font-size:0;">&nbsp;</td></tr>

    <!-- BANNER META -->
    <tr><td style="background:linear-gradient(135deg,#001a55,#0035a0);padding:24px 30px;text-align:center;">
      <div style="font-size:36px;line-height:1;margin-bottom:10px;">🏆</div>
      <div style="color:#F7A800;font-size:24px;font-weight:900;letter-spacing:.06em;">¡META ALCANZADA!</div>
      <div style="display:inline-block;background:rgba(255,255,255,.1);border-radius:20px;padding:6px 20px;margin-top:10px;">
        <span style="color:rgba(255,255,255,.9);font-size:13px;font-weight:bold;">${tienda.nombre}</span>
        <span style="color:rgba(255,255,255,.4);font-size:13px;"> &nbsp;·&nbsp; </span>
        <span style="color:rgba(255,255,255,.7);font-size:13px;">${semana_nombre}</span>
      </div>
    </td></tr>

    <!-- MENSAJE -->
    <tr><td style="background:#050c2e;padding:28px 34px 20px;">
      <p style="color:rgba(255,255,255,.85);line-height:1.75;margin:0;font-size:14.5px;">
        ¡Excelentes noticias! ${total === 1
          ? 'Un asesor de tu equipo alcanzó'
          : `<strong style="color:#F7A800;">${total} asesores</strong> de tu equipo alcanzaron`}
        el <strong style="color:#F7A800;">100% de su meta de ventas</strong> esta semana.
        Su espacio en el <strong style="color:#fff;">Álbum Estrellas</strong> está desbloqueado — ¡es hora de subir su figurita! 📸
      </p>
    </td></tr>

    <!-- SEPARADOR FIGURITAS -->
    <tr><td style="background:#050c2e;padding:0 34px 6px;text-align:center;">
      <div style="border-top:1px solid rgba(247,168,0,.2);padding-top:18px;color:rgba(247,168,0,.6);font-size:10px;letter-spacing:.2em;font-weight:bold;">✦ &nbsp; FIGURITAS DESBLOQUEADAS &nbsp; ✦</div>
    </td></tr>

    <!-- TARJETAS -->
    <tr><td style="background:#050c2e;padding:12px 20px 28px;">
      <table width="100%" cellpadding="0" cellspacing="0">${filas.join('')}</table>
    </td></tr>

    <!-- CTA -->
    <tr><td style="background:#050c2e;padding:0 30px 36px;text-align:center;">
      <a href="${frontendUrl}/album.html"
         style="display:inline-block;padding:15px 44px;background:linear-gradient(135deg,#F7A800,#d98c00);color:#000;text-decoration:none;border-radius:50px;font-weight:900;font-size:15px;letter-spacing:.03em;">
        📷 &nbsp;Ir al Álbum y Subir Foto
      </a>
    </td></tr>

    <!-- FOOTER -->
    <tr><td style="background:#02061a;border-radius:0 0 18px 18px;border-top:1.5px solid rgba(247,168,0,.25);padding:18px 30px;text-align:center;">
      <p style="color:rgba(255,255,255,.2);font-size:10px;margin:0;letter-spacing:.07em;line-height:1.8;">
        SLA CORP. · ÁLBUM ESTRELLAS · FIFA MUNDIAL 2026<br>
        Correo automático — no responder.
      </p>
    </td></tr>

  </table>
</td></tr></table>
</body></html>`;

    const respEmail = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: {
        'api-key': apiKey,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        sender: { name: 'Álbum Estrellas · SLA Corp.', email: process.env.BREVO_SENDER || 'conectados@sportline.com.pa' },
        to: [{ email: destinatario }],
        subject: `⭐ ${total} asesor${total !== 1 ? 'es' : ''} desbloquearon su figurita — ${semana_nombre}`,
        htmlContent: htmlBody
      })
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
