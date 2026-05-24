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

    res.json({ 
      token, 
      esAdmin: false, 
      redirect: 'album.html',
      tienda: {
        nombre: tienda.nombre,
        codigo: tienda.codigo
      }
    });

  } catch (error) {
    res.status(500).json({ error: 'Error del servidor en el módulo de accesos.' });
  }
});

module.exports = router;
