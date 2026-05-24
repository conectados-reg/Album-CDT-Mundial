const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');
const nodemailer = require('nodemailer');

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

    const { data, error } = await supabase
      .from('resultados_ventas')
      .select('empleados(nombre, cargo, tiendas(id, nombre, email))')
      .eq('semana_id', semana.id)
      .eq('cumplio_meta', true);
    if (error) throw error;

    const porTienda = {};
    for (const r of (data || [])) {
      const t = r.empleados?.tiendas;
      if (!t) continue;
      if (!porTienda[t.id]) {
        porTienda[t.id] = { tienda_id: t.id, nombre: t.nombre, email: t.email || '', empleados: [] };
      }
      porTienda[t.id].empleados.push({ nombre: r.empleados.nombre, cargo: r.empleados.cargo });
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

    if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
      return res.status(503).json({ error: 'Servicio de email no configurado en el servidor.' });
    }

    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.SMTP_PORT || '587'),
      secure: false,
      auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS }
    });

    const listaHtml = (empleados || [])
      .map(e => `<li style="margin:.4em 0;"><strong>${e.nombre}</strong> <span style="color:#666;">— ${e.cargo}</span></li>`)
      .join('');

    const frontendUrl = process.env.FRONTEND_URL || 'https://album-cdt-mundial.onrender.com';

    await transporter.sendMail({
      from: `"Álbum Estrellas Sportline" <${process.env.SMTP_USER}>`,
      to: tienda.email,
      subject: `⭐ Semana ${semana_numero}: ¡${empleados?.length || 0} asesor(es) desbloquearon su espacio!`,
      html: `<!DOCTYPE html><html><body style="margin:0;padding:0;background:#f5f5f5;font-family:Arial,sans-serif;">
<table width="100%" cellpadding="0" cellspacing="0"><tr><td align="center" style="padding:2em 1em;">
<table width="600" style="background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 16px rgba(0,0,0,.1);">
<tr><td style="background:linear-gradient(90deg,#000d2e,#001a55);padding:2em;text-align:center;">
  <p style="color:#F7A800;font-size:2.5em;margin:0;">⭐</p>
  <h1 style="color:#fff;margin:.3em 0 .1em;font-size:1.6em;">ÁLBUM ESTRELLAS</h1>
  <p style="color:rgba(255,255,255,.5);margin:0;font-size:.85em;">SPORTLINE · FIFA MUNDIAL 2026</p>
</td></tr>
<tr><td style="padding:2em;">
  <h2 style="color:#0046AD;margin-top:0;">¡Felicitaciones, ${tienda.nombre}!</h2>
  <p style="color:#333;line-height:1.6;">En <strong>${semana_nombre}</strong>, los siguientes asesores alcanzaron el <span style="color:#F7A800;font-weight:bold;">100% de su meta de ventas</span>:</p>
  <ul style="background:#f8f8f8;border-left:4px solid #F7A800;padding:1em 1em 1em 2em;border-radius:4px;">${listaHtml}</ul>
  <p style="color:#333;line-height:1.6;">Su espacio en el <strong>Álbum Estrellas</strong> está <span style="color:#00c853;font-weight:bold;">DESBLOQUEADO</span>. Ingresen al sistema para subir la foto de celebración.</p>
  <div style="text-align:center;margin:2em 0;">
    <a href="${frontendUrl}/album.html" style="display:inline-block;padding:1em 2em;background:#F7A800;color:#000;text-decoration:none;border-radius:8px;font-weight:bold;font-size:1.1em;">📷 Ir al Álbum</a>
  </div>
</td></tr>
<tr><td style="background:#f0f0f0;padding:1em;text-align:center;">
  <p style="color:#999;font-size:.75em;margin:0;">Sportline Corp · Álbum Estrellas · FIFA Mundial 2026</p>
</td></tr>
</table></td></tr></table></body></html>`
    });

    res.json({ ok: true, email: tienda.email });
  } catch (err) {
    console.error('[Email enviar]', err.message);
    res.status(500).json({ error: `Error al enviar: ${err.message}` });
  }
});

module.exports = router;
