const router   = require('express').Router();
const bcrypt   = require('bcryptjs');
const jwt      = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

router.post('/login', async (req, res) => {
  const { codigo, password } = req.body;
  if (!codigo || !password) return res.status(400).json({ error: 'Faltan campos obligatorios.' });

  try {
    // 1. Intentar validar si es Administrador (Buscando por Email)
    if (codigo.includes('@')) {
      const { data: admin } = await supabase.from('admins').select('*').eq('email', codigo.trim().toLowerCase()).single();
      if (admin && await bcrypt.compare(password, admin.password_hash)) {
        const token = jwt.sign({ id: admin.id, rol: 'admin' }, process.env.JWT_SECRET, { expiresIn: '24h' });
        return res.json({ token, esAdmin: true, nombre: admin.nombre });
      }
    }

    // 2. Si no es admin, validar como Tienda regular
    const { data: tienda } = await supabase.from('tiendas').select('*').eq('codigo', codigo.trim().toUpperCase()).single();
    if (!tienda || !tienda.activa) return res.status(401).json({ error: 'Credenciales inválidas o cuenta inactiva.' });

    const passwordCorrecto = await bcrypt.compare(password, tienda.password_hash);
    if (!passwordCorrecto) return res.status(401).json({ error: 'Contraseña incorrecta.' });

    const token = jwt.sign({ tiendaId: tienda.id, codigo: tienda.codigo, rol: 'tienda' }, process.env.JWT_SECRET, { expiresIn: '24h' });
    res.json({ token, esAdmin: false, tiendaId: tienda.id, nombre: tienda.nombre, codigo: tienda.codigo });

  } catch (err) {
    res.status(500).json({ error: 'Error interno en el servidor.' });
  }
});

module.exports = router;
