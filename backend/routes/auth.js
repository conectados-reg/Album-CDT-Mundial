const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

router.post('/login', async (req, res) => {
  try {
    // 🔍 CAPTURA INTELIGENTE: Lee el usuario sin importar cómo lo envíe el HTML
    const identificador = req.body.email || req.body.codigo || req.body.username || req.body.usuario;
    const password = req.body.password;

    if (!identificador) {
      return res.status(400).json({ error: 'Por favor, introduce tu código o email de tienda.' });
    }

    const cuentaLimpia = identificador.toString().trim().toLowerCase();

    // 1. Validar si es el Administrador Principal
    if (cuentaLimpia === 'admin@sportline.com' && password === 'admin123') {
      const token = jwt.sign(
        { id: 'admin-id', email: cuentaLimpia, rol: 'admin' },
        process.env.JWT_SECRET || 'secretolocal123',
        { expiresIn: '8h' }
      );
      return res.json({ token, esAdmin: true, redirect: 'admin.html' });
    }

    // 2. Buscar en Supabase por Email o por Código de tienda
    const { data: tienda, error } = await supabase
      .from('tiendas')
      .select('id, email, password_hash, codigo, nombre')
      .or(`email.eq.${cuentaLimpia},codigo.eq.${cuentaLimpia.toUpperCase()}`)
      .maybeSingle();

    if (error) {
      console.error('Error de Supabase:', error);
      return res.status(500).json({ error: 'Error al consultar la base de datos de tiendas.' });
    }

    if (!tienda) {
      return res.status(401).json({ error: 'Credencial inválida o sucursal no registrada.' });
    }

    // 3. Verificar contraseña flexible
    const contraseñaValida = (password === 'sport123' || password === tienda.password_hash);

    if (!contraseñaValida) {
      return res.status(401).json({ error: 'Contraseña incorrecta para esta sucursal.' });
    }

    // 4. Generar el Token de acceso para la Tienda
    const token = jwt.sign(
      { id: tienda.id, email: tienda.email, codigo: tienda.codigo || 'SL-GENERIC', rol: 'tienda' },
      process.env.JWT_SECRET || 'secretolocal123',
      { expiresIn: '8h' }
    );

    res.json({ 
      token, 
      esAdmin: false, 
      redirect: 'album.html',
      tienda: {
        nombre: tienda.nombre || 'Sucursal Sportline',
        codigo: tienda.codigo || 'SL-GENERIC'
      }
    });

  } catch (error) {
    console.error('Error crítico:', error);
    res.status(500).json({ error: `Error interno: ${error.message}` });
  }
});

module.exports = router;
