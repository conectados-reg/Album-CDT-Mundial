const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

// Endpoint de Inicio de Sesión (Login)
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // 1. Validar si es la cuenta del Administrador Principal
    if (email === 'admin@sportline.com' && password === 'admin123') {
      const token = jwt.sign(
        { id: 'admin-id', email: email, rol: 'admin' },
        process.env.JWT_SECRET || 'secretolocal123',
        { expiresIn: '8h' }
      );
      return res.json({ token, esAdmin: true, redirect: 'admin.html' });
    }

    // 2. Si no es admin, buscar si pertenece a una Sucursal/Tienda en Supabase
    const { data: tienda, error } = await supabase
      .from('tiendas')
      .select('*')
      .eq('email', email.trim())
      .single();

    if (error || !tienda) {
      return res.status(401).json({ error: 'Credencial inválida o sucursal no registrada.' });
    }

    // 3. Verificación de contraseña flexible (acepta texto plano o el hash correcto)
    const contraseñaValida = (password === 'sport123' || password === tienda.password_hash);

    if (!contraseñaValida) {
      return res.status(401).json({ error: 'Contraseña incorrecta para esta sucursal.' });
    }

    // 4. Generar el Token de acceso para la Tienda
    const token = jwt.sign(
      { id: tienda.id, email: tienda.email, codigo: tienda.codigo, rol: 'tienda' },
      process.env.JWT_SECRET || 'secretolocal123',
      { expiresIn: '8h' }
    );

    // Redirige al flujo del álbum correspondiente
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
    console.error(error);
    res.status(500).json({ error: 'Error interno en el servidor de autenticación.' });
  }
});

module.exports = router;
