const router = require('express').Router();
const jwt    = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

// ── helpers ──────────────────────────────────────────────────────────────────

const JWT_SECRET   = process.env.JWT_SECRET;
const ADMIN_EMAIL  = process.env.ADMIN_EMAIL;
const ADMIN_PASS   = process.env.ADMIN_PASSWORD;
const PASS_GEN     = 'sport123'; // contraseña genérica de primer acceso

if (!JWT_SECRET)  throw new Error('Falta variable de entorno: JWT_SECRET');
if (!ADMIN_EMAIL) throw new Error('Falta variable de entorno: ADMIN_EMAIL');
if (!ADMIN_PASS)  throw new Error('Falta variable de entorno: ADMIN_PASSWORD');

function esBcrypt(str) {
  return typeof str === 'string' && str.startsWith('$2');
}

async function verificarPassword(ingresada, almacenada) {
  if (!almacenada || almacenada === PASS_GEN) return ingresada === PASS_GEN;
  if (esBcrypt(almacenada)) return bcrypt.compare(ingresada, almacenada);
  return ingresada === almacenada; // legacy texto plano distinto a sport123
}

// ── POST /api/auth/login ──────────────────────────────────────────────────────
router.post('/login', async (req, res) => {
  try {
    const email    = (req.body.email    || '').toString().trim().toLowerCase();
    const password = (req.body.password || '').toString();

    if (!email || !password)
      return res.status(400).json({ error: 'Por favor completa todos los campos.' });

    // Admin via variables de entorno
    if (email === ADMIN_EMAIL && password === ADMIN_PASS) {
      const token = jwt.sign({ id: 'admin-id', email, rol: 'admin' }, JWT_SECRET, { expiresIn: '12h' });
      res.cookie('token', token, {
        httpOnly: true,
        secure:   true,
        sameSite: 'lax',
        maxAge:   12 * 60 * 60 * 1000,  // 12h
        path:     '/',
      });
      return res.json({ token, esAdmin: true, redirect: 'admin.html' });
    }

    // Tienda en Supabase
    const { data: tienda, error } = await supabase
      .from('tiendas')
      .select('id, email, password_hash, codigo, nombre, activa')
      .eq('email', email)
      .maybeSingle();

    if (error) return res.status(500).json({ error: 'Error al consultar la base de datos.' });
    if (!tienda) return res.status(401).json({ error: 'La sucursal no está registrada en el sistema.' });
    if (tienda.activa === false) return res.status(403).json({ error: 'Esta sucursal está desactivada.' });

    const contraseñaValida = await verificarPassword(password, tienda.password_hash);
    if (!contraseñaValida)
      return res.status(401).json({ error: 'Contraseña incorrecta para esta sucursal.' });

    const token = jwt.sign(
      { id: tienda.id, email: tienda.email, codigo: tienda.codigo, rol: 'tienda' },
      JWT_SECRET,
      { expiresIn: '8h' }
    );

    // Primer acceso: contraseña genérica aún sin cambiar
    const primerAcceso = !tienda.password_hash || tienda.password_hash === PASS_GEN;

    res.cookie('token', token, {
      httpOnly: true,
      secure:   true,
      sameSite: 'lax',
      maxAge:   8 * 60 * 60 * 1000,  // 8h
      path:     '/',
    });

    res.json({
      token,
      esAdmin:      false,
      redirect:     primerAcceso ? 'cambiar-clave.html' : 'album.html',
      primerAcceso,
      tienda: { nombre: tienda.nombre, codigo: tienda.codigo },
    });

  } catch (err) {
    console.error('[Login]', err.message);
    res.status(500).json({ error: 'Error del servidor en el módulo de accesos.' });
  }
});

// ── GET /api/auth/me ─────────────────────────────────────────────────────────
router.get('/me', (req, res) => {
  const token = req.cookies?.token || req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'No autenticado.' });
  try {
    const u = jwt.verify(token, JWT_SECRET);
    res.json({ id: u.id, email: u.email, rol: u.rol, codigo: u.codigo });
  } catch {
    res.status(401).json({ error: 'Sesión inválida.' });
  }
});

// ── POST /api/auth/logout ─────────────────────────────────────────────────────
router.post('/logout', (req, res) => {
  res.clearCookie('token', { httpOnly: true, secure: true, sameSite: 'lax', path: '/' });
  res.json({ ok: true });
});

// ── PUT /api/auth/cambiar-clave ───────────────────────────────────────────────
router.put('/cambiar-clave', async (req, res) => {
  let usuario;
  try {
    const token = req.cookies?.token || req.headers.authorization?.split(' ')[1];
    usuario = jwt.verify(token, JWT_SECRET);
  } catch {
    return res.status(401).json({ error: 'Sesión inválida.' });
  }

  if (usuario.rol !== 'tienda')
    return res.status(403).json({ error: 'Solo las sucursales pueden cambiar su contraseña.' });

  const { passwordActual, passwordNueva } = req.body;
  if (!passwordActual || !passwordNueva)
    return res.status(400).json({ error: 'Completa todos los campos requeridos.' });
  if (passwordNueva.length < 6)
    return res.status(400).json({ error: 'La contraseña nueva debe tener mínimo 6 caracteres.' });
  if (passwordNueva === PASS_GEN)
    return res.status(400).json({ error: 'No puedes usar la contraseña genérica como contraseña personal.' });

  try {
    const { data: tienda, error } = await supabase
      .from('tiendas').select('id, password_hash').eq('id', usuario.id).maybeSingle();

    if (error || !tienda) return res.status(404).json({ error: 'Sucursal no encontrada.' });

    const valida = await verificarPassword(passwordActual, tienda.password_hash);
    if (!valida) return res.status(401).json({ error: 'La contraseña actual es incorrecta.' });

    const nuevoHash = await bcrypt.hash(passwordNueva, 10);

    const { error: updateError } = await supabase.from('tiendas').update({
      password_hash:       nuevoHash,
      password_changed_at: new Date().toISOString(),
    }).eq('id', tienda.id);

    if (updateError) throw updateError;

    res.json({ ok: true, mensaje: 'Contraseña actualizada correctamente.' });

  } catch (err) {
    console.error('[CambiarClave]', err.message);
    res.status(500).json({ error: 'Error del servidor al actualizar la contraseña.', detalle: err.message });
  }
});

// ── POST /api/auth/olvide-clave ───────────────────────────────────────────────
router.post('/olvide-clave', async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: 'Ingresa el correo de tu sucursal.' });

  try {
    const { data: tienda } = await supabase
      .from('tiendas').select('id, nombre').eq('email', email.toString().trim().toLowerCase()).maybeSingle();

    res.json({
      ok: true,
      encontrada: !!tienda,
      mensaje: tienda
        ? `Solicitud recibida para "${tienda.nombre}". El administrador restablecerá tu acceso.`
        : 'Si el correo está registrado, el administrador podrá restablecer tu acceso.',
    });
  } catch {
    res.status(500).json({ error: 'Error del servidor. Intenta de nuevo.' });
  }
});

module.exports = router;
