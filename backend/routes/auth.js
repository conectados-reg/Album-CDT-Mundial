const router = require('express').Router();
const admin  = require('../firebase-admin');
const db     = require('../db');

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const email    = req.body.email?.toString().trim().toLowerCase();
    const password = req.body.password;

    if (!email || !password) {
      return res.status(400).json({ error: 'Por favor completa todos los campos.' });
    }

    // 1. Administrador principal
    if (email === 'admin@sportline.com' && password === (process.env.ADMIN_PASSWORD || 'admin123')) {
      const customToken = await admin.auth().createCustomToken('admin-super-uid', { rol: 'admin' });
      return res.json({ customToken, esAdmin: true, redirect: 'admin.html' });
    }

    // 2. Tiendas/Sucursales en Cloud SQL
    const tienda = await db.one(
      'SELECT id, email, password_hash, codigo, nombre FROM tiendas WHERE email = $1',
      [email]
    );

    if (!tienda) {
      return res.status(401).json({ error: 'La sucursal seleccionada no está registrada en el sistema.' });
    }

    const contraseñaValida = password === 'sport123' || password === tienda.password_hash;
    if (!contraseñaValida) {
      return res.status(401).json({ error: 'Contraseña incorrecta para esta sucursal.' });
    }

    // Firebase custom token — uid = tienda.id para que el backend pueda verificar claims
    const customToken = await admin.auth().createCustomToken(tienda.id, {
      rol:       'tienda',
      tienda_id: tienda.id,
      codigo:    tienda.codigo,
    });

    const requiereCambio = !tienda.password_hash || tienda.password_hash === 'sport123';

    res.json({
      customToken,
      esAdmin: false,
      redirect: 'album.html',
      requiereCambio,
      tienda: { nombre: tienda.nombre, codigo: tienda.codigo },
    });

  } catch (err) {
    console.error('[Login]', err.message);
    res.status(500).json({ error: 'Error del servidor en el módulo de accesos.' });
  }
});

// Middleware exportado para otros routers
async function verificarToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token faltante.' });
  try {
    const decoded = await admin.auth().verifyIdToken(token);
    req.usuario = {
      id:     decoded.uid,
      email:  decoded.email,
      rol:    decoded.rol || 'tienda',
      codigo: decoded.codigo,
    };
    next();
  } catch {
    res.status(401).json({ error: 'Sesión inválida.' });
  }
}

// PUT /api/auth/cambiar-clave
router.put('/cambiar-clave', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') {
    return res.status(403).json({ error: 'Solo las sucursales pueden cambiar su contraseña.' });
  }

  const { passwordActual, passwordNueva } = req.body;
  if (!passwordActual || !passwordNueva) {
    return res.status(400).json({ error: 'Completa todos los campos requeridos.' });
  }
  if (passwordNueva.length < 6) {
    return res.status(400).json({ error: 'La contraseña nueva debe tener mínimo 6 caracteres.' });
  }

  try {
    const tienda = await db.one('SELECT id, password_hash FROM tiendas WHERE id = $1', [req.usuario.id]);
    if (!tienda) return res.status(404).json({ error: 'Sucursal no encontrada en el sistema.' });

    const valida = passwordActual === 'sport123' || passwordActual === tienda.password_hash;
    if (!valida) return res.status(401).json({ error: 'La contraseña actual es incorrecta.' });

    await db.query('UPDATE tiendas SET password_hash = $1 WHERE id = $2', [passwordNueva, tienda.id]);
    res.json({ ok: true, mensaje: 'Contraseña actualizada correctamente.' });
  } catch (err) {
    console.error('[CambiarClave]', err.message);
    res.status(500).json({ error: 'Error del servidor al actualizar la contraseña.' });
  }
});

// POST /api/auth/olvide-clave
router.post('/olvide-clave', async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: 'Ingresa el correo de tu sucursal.' });

  try {
    const tienda = await db.one(
      'SELECT id, nombre FROM tiendas WHERE email = $1',
      [email.toString().trim().toLowerCase()]
    );
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
module.exports.verificarToken = verificarToken;
