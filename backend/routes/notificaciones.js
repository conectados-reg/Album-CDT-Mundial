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

    const listaHtml = (empleados || [])
      .map(e => `
        <tr>
          <td style="padding:.6em .8em;border-bottom:1px solid #f0f0f0;">
            <span style="font-size:1.1em;">⭐</span>
          </td>
          <td style="padding:.6em .8em;border-bottom:1px solid #f0f0f0;">
            <strong style="color:#000d2e;font-size:.95em;">${e.nombre}</strong><br>
            <span style="color:#888;font-size:.8em;">${e.cargo}</span>
          </td>
          <td style="padding:.6em .8em;border-bottom:1px solid #f0f0f0;text-align:right;">
            <span style="background:#e8f5e9;color:#2e7d32;font-weight:bold;font-size:.85em;padding:.2em .6em;border-radius:12px;">✓ 100%</span>
          </td>
        </tr>`).join('');

    const frontendUrl = process.env.FRONTEND_URL || 'https://album-cdt-mundial.onrender.com';
    const total = empleados?.length || 0;

    const htmlBody = `<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#f0f2f5;font-family:Arial,Helvetica,sans-serif;">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f0f2f5;">
<tr><td align="center" style="padding:2.5em 1em;">

  <table width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%;background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 8px 32px rgba(0,0,0,.12);">

    <!-- HEADER -->
    <tr><td style="background:linear-gradient(135deg,#000d2e 0%,#001a55 60%,#0046AD 100%);padding:2.5em 2em;text-align:center;">
      <div style="font-size:3em;margin-bottom:.3em;">🏆</div>
      <h1 style="color:#F7A800;font-size:1.8em;margin:0 0 .2em;letter-spacing:.08em;font-family:Georgia,serif;">¡MISIÓN CUMPLIDA!</h1>
      <p style="color:rgba(255,255,255,.7);margin:0;font-size:.9em;letter-spacing:.06em;">ÁLBUM ESTRELLAS · SLA CORP. · FIFA MUNDIAL 2026</p>
    </td></tr>

    <!-- SALUDO -->
    <tr><td style="padding:2em 2em 1em;">
      <h2 style="color:#000d2e;margin:0 0 .5em;font-size:1.2em;">¡Felicitaciones, ${tienda.nombre}! 🎉</h2>
      <p style="color:#444;line-height:1.7;margin:0;">En <strong>${semana_nombre}</strong>, ${total === 1 ? 'el siguiente asesor alcanzó' : `los siguientes <strong>${total} asesores</strong> alcanzaron`} el <strong style="color:#F7A800;">100% de su meta de ventas</strong> y desbloquearon su espacio en el Álbum Estrellas:</p>
    </td></tr>

    <!-- TABLA DE ESTRELLAS -->
    <tr><td style="padding:0 2em 1.5em;">
      <table width="100%" cellpadding="0" cellspacing="0" style="border:1.5px solid #F7A800;border-radius:10px;overflow:hidden;">
        <tr style="background:#000d2e;">
          <td colspan="3" style="padding:.6em 1em;font-size:.7em;letter-spacing:.12em;color:#F7A800;font-weight:bold;">ASESORES AL 100% · ${semana_nombre?.toUpperCase()}</td>
        </tr>
        ${listaHtml}
      </table>
    </td></tr>

    <!-- MENSAJE -->
    <tr><td style="padding:0 2em 1.5em;">
      <div style="background:#fffde7;border-left:4px solid #F7A800;padding:1em 1.2em;border-radius:4px;">
        <p style="margin:0;color:#5d4037;font-size:.9em;line-height:1.6;">
          📷 Su espacio en el álbum está <strong>desbloqueado</strong>. Ingresen al sistema y suban su foto — ¡su figurita Panini los espera!
        </p>
      </div>
    </td></tr>

    <!-- BOTÓN CTA -->
    <tr><td style="padding:0 2em 2.5em;text-align:center;">
      <a href="${frontendUrl}/album.html" style="display:inline-block;padding:.9em 2.5em;background:linear-gradient(135deg,#F7A800,#e69500);color:#000d2e;text-decoration:none;border-radius:30px;font-weight:bold;font-size:1em;letter-spacing:.04em;box-shadow:0 4px 16px rgba(247,168,0,.4);">
        ⭐ Subir mi Foto al Álbum
      </a>
    </td></tr>

    <!-- FOOTER -->
    <tr><td style="background:#f8f8f8;border-top:1px solid #eee;padding:1.2em 2em;text-align:center;">
      <p style="color:#aaa;font-size:.72em;margin:0;">SLA Corp. · Álbum Estrellas · FIFA Mundial 2026<br>
      <span style="font-size:.9em;">Este correo fue enviado automáticamente — no responder.</span></p>
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
