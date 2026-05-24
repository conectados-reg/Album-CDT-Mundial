const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function verificarToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token faltante.' });
  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET || 'secretomocal123');
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
      filas.push(`<tr>${grupo.map((e, j) => e
        ? `<td width="33%" style="padding:6px;vertical-align:top;text-align:center;">
            <table width="100%" cellpadding="0" cellspacing="0" style="background:linear-gradient(180deg,#001a55,#000d2e);border-radius:10px;border:1.5px solid rgba(247,168,0,0.5);">
              <tr><td style="background:linear-gradient(90deg,#F7A800,#e69500);height:5px;font-size:0;">&nbsp;</td></tr>
              <tr><td style="padding:12px 8px 6px;text-align:center;">
                <div style="font-size:2em;">⭐</div>
                <div style="background:rgba(247,168,0,.2);color:#F7A800;font-size:8px;letter-spacing:.1em;padding:2px 6px;border-radius:10px;margin:5px auto;display:inline-block;font-weight:bold;">✓ 100%</div>
              </td></tr>
              <tr><td style="background:rgba(0,0,0,.3);padding:7px 8px;border-top:1px solid rgba(255,255,255,.07);">
                <div style="color:#fff;font-size:10px;font-weight:bold;line-height:1.3;">${e.nombre}</div>
                <div style="color:rgba(255,255,255,.45);font-size:8px;margin-top:2px;">${e.cargo || 'Asesor de Ventas'}</div>
              </td></tr>
            </table>
           </td>`
        : `<td width="33%" style="padding:6px;"></td>`).join('')}</tr>`);
    }

    const htmlBody = `<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Álbum Estrellas · SLA Corp.</title></head>
<body style="margin:0;padding:0;background:#000d2e;font-family:Arial,Helvetica,sans-serif;">
<table width="100%" cellpadding="0" cellspacing="0" style="background:linear-gradient(180deg,#000d2e,#001a55);">
<tr><td align="center" style="padding:2em 1em;">

  <table width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%;">

    <!-- LOGO + HEADER -->
    <tr><td style="background:linear-gradient(135deg,#000d2e,#001f5e,#0046AD);border-radius:16px 16px 0 0;padding:2.5em 2em 2em;text-align:center;border:1px solid rgba(247,168,0,.2);border-bottom:none;">
      <img src="https://i.postimg.cc/hv6YBVfc/logo-sla.png" alt="SLA Corp." width="90" style="margin-bottom:1em;filter:drop-shadow(0 0 12px rgba(247,168,0,.5));" onerror="this.style.display='none'">
      <div style="display:inline-block;background:rgba(247,168,0,.15);border:1px solid rgba(247,168,0,.4);border-radius:20px;padding:.3em 1em;margin-bottom:.8em;">
        <span style="color:#F7A800;font-size:.7em;letter-spacing:.15em;font-weight:bold;">⚽ FIFA MUNDIAL 2026</span>
      </div>
      <h1 style="color:#fff;font-size:2em;margin:.2em 0 .1em;letter-spacing:.06em;">ÁLBUM <span style="color:#F7A800;">ESTRELLAS</span></h1>
      <p style="color:rgba(255,255,255,.5);margin:0;font-size:.78em;letter-spacing:.1em;">SLA CORP. · TEMPORADA MUNDIAL 2026</p>
    </td></tr>

    <!-- BANNER META CUMPLIDA -->
    <tr><td style="background:linear-gradient(90deg,#0046AD,#001f5e);padding:1.2em 2em;text-align:center;border-left:1px solid rgba(247,168,0,.2);border-right:1px solid rgba(247,168,0,.2);">
      <div style="font-size:1.4em;margin-bottom:.3em;">🏆</div>
      <h2 style="color:#F7A800;margin:0;font-size:1.4em;letter-spacing:.05em;">¡META ALCANZADA!</h2>
      <p style="color:rgba(255,255,255,.75);margin:.4em 0 0;font-size:.88em;">${tienda.nombre} · ${semana_nombre}</p>
    </td></tr>

    <!-- MENSAJE -->
    <tr><td style="background:#001233;padding:1.8em 2em 1.2em;border-left:1px solid rgba(247,168,0,.2);border-right:1px solid rgba(247,168,0,.2);">
      <p style="color:rgba(255,255,255,.8);line-height:1.7;margin:0;font-size:.92em;">
        ¡Excelentes noticias! ${total === 1
          ? 'Un asesor de tu equipo alcanzó'
          : `<strong style="color:#F7A800;">${total} asesores</strong> de tu equipo alcanzaron`}
        el <strong style="color:#F7A800;">100% de su meta de ventas</strong> esta semana.
        Su espacio en el <strong>Álbum Estrellas</strong> está desbloqueado — ¡es hora de subir su figurita! 📸
      </p>
    </td></tr>

    <!-- FIGURITAS / TARJETAS -->
    <tr><td style="background:#001233;padding:.5em 1.5em 1.8em;border-left:1px solid rgba(247,168,0,.2);border-right:1px solid rgba(247,168,0,.2);">
      <div style="color:rgba(255,255,255,.35);font-size:.65em;letter-spacing:.15em;text-align:center;margin-bottom:.8em;">— FIGURITAS DESBLOQUEADAS —</div>
      <table width="100%" cellpadding="0" cellspacing="0">${filas.join('')}</table>
    </td></tr>

    <!-- CTA -->
    <tr><td style="background:#001233;padding:0 2em 2.5em;text-align:center;border-left:1px solid rgba(247,168,0,.2);border-right:1px solid rgba(247,168,0,.2);">
      <a href="${frontendUrl}/album.html"
         style="display:inline-block;padding:.85em 2.5em;background:linear-gradient(135deg,#F7A800,#e69500);color:#000d2e;text-decoration:none;border-radius:30px;font-weight:bold;font-size:1em;letter-spacing:.04em;box-shadow:0 6px 20px rgba(247,168,0,.4);">
        📷 Ir al Álbum y Subir Foto
      </a>
    </td></tr>

    <!-- FOOTER -->
    <tr><td style="background:rgba(0,0,0,.4);border:1px solid rgba(247,168,0,.15);border-top:1px solid rgba(247,168,0,.2);border-radius:0 0 16px 16px;padding:1.2em 2em;text-align:center;">
      <p style="color:rgba(255,255,255,.25);font-size:.68em;margin:0;letter-spacing:.06em;">
        SLA CORP. · ÁLBUM ESTRELLAS · FIFA MUNDIAL 2026<br>
        <span style="font-size:.85em;">Correo automático — no responder.</span>
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
