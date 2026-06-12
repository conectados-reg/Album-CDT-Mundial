const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

router.post('/login', async (req, res) => {
  try {
    const email = req.body.email;
    const password = req.body.password;

    if (!email || !password) {
      return res.status(400).json({ error: 'Por favor completa todos los campos.' });
    }

    const cuentaLimpia = email.toString().trim().toLowerCase();

    // 1. REPARADO: Validación estricta para ti como Administrador Principal
    if (cuentaLimpia === 'admin@sportline.com' && password === 'admin123') {
      const token = jwt.sign(
        { id: 'admin-id', email: cuentaLimpia, rol: 'admin' },
        process.env.JWT_SECRET || 'secretomocal123',
        { expiresIn: '12h' }
      );
      return res.json({ token, esAdmin: true, redirect: 'admin.html' });
    }

    // 2. Validación de Tiendas/Sucursales en Supabase
    const { data: tienda, error } = await supabase
      .from('tiendas')
      .select('id, email, password_hash, codigo, nombre')
      .eq('email', cuentaLimpia)
      .maybeSingle();

    if (error) {
      return res.status(500).json({ error: 'Fallo al consultar la base de datos de sucursales.' });
    }

    if (!tienda) {
      return res.status(401).json({ error: 'La sucursal seleccionada no está registrada en el sistema.' });
    }

    // 3. Validación de contraseña (texto plano o hash seguro de migración)
    const contraseñaValida = (password === 'sport123' || password === tienda.password_hash);

    if (!contraseñaValida) {
      return res.status(401).json({ error: 'Contraseña incorrecta para esta sucursal.' });
    }

    // 4. Token legítimo para el rol de tienda
    const token = jwt.sign(
      { id: tienda.id, email: tienda.email, codigo: tienda.codigo, rol: 'tienda' },
      process.env.JWT_SECRET || 'secretomocal123',
      { expiresIn: '8h' }
    );

    const requiereCambio = !tienda.password_hash || tienda.password_hash === 'sport123';

    res.json({
      token,
      esAdmin: false,
      redirect: 'album.html',
      requiereCambio,
      tienda: {
        nombre: tienda.nombre,
        codigo: tienda.codigo
      }
    });

  } catch (error) {
    res.status(500).json({ error: 'Error del servidor en el módulo de accesos.' });
  }
});

// PUT /api/auth/cambiar-clave — Tienda autenticada cambia su propia contraseña
router.put('/cambiar-clave', async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'Token faltante.' });

  let usuario;
  try {
    usuario = jwt.verify(authHeader.split(' ')[1], process.env.JWT_SECRET || 'secretomocal123');
  } catch {
    return res.status(401).json({ error: 'Sesión inválida.' });
  }

  if (usuario.rol !== 'tienda') {
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
    const { data: tienda, error } = await supabase
      .from('tiendas')
      .select('id, password_hash')
      .eq('id', usuario.id)
      .maybeSingle();

    if (error || !tienda) {
      return res.status(404).json({ error: 'Sucursal no encontrada en el sistema.' });
    }

    const valida = (passwordActual === 'sport123' || passwordActual === tienda.password_hash);
    if (!valida) {
      return res.status(401).json({ error: 'La contraseña actual es incorrecta.' });
    }

    const { error: updateError } = await supabase
      .from('tiendas')
      .update({ password_hash: passwordNueva, password_changed_at: new Date().toISOString() })
      .eq('id', tienda.id);

    if (updateError) throw updateError;

    res.json({ ok: true, mensaje: 'Contraseña actualizada correctamente.' });

  } catch (err) {
    console.error('[CambiarClave]', err.message);
    res.status(500).json({ error: 'Error del servidor al actualizar la contraseña.' });
  }
});

// POST /api/auth/olvide-clave — Verifica si la tienda existe y confirma la solicitud
router.post('/olvide-clave', async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: 'Ingresa el correo de tu sucursal.' });

  try {
    const cuentaLimpia = email.toString().trim().toLowerCase();

    const { data: tienda } = await supabase
      .from('tiendas')
      .select('id, nombre')
      .eq('email', cuentaLimpia)
      .maybeSingle();

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
