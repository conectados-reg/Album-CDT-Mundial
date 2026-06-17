const router = require('express').Router();
const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

function verificarToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token faltante.' });
  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Sesión inválida.' });
  }
}

// GET /api/empleados — empleados activos de la tienda autenticada
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  try {
    const { data, error } = await supabase
      .from('empleados')
      .select('id, nombre, cargo, foto_url, created_at')
      .eq('tienda_id', req.usuario.id)
      .eq('activo', true)
      .order('nombre');
    if (error) throw error;
    res.json({ empleados: data || [] });
  } catch (err) {
    console.error('[Empleados GET]', err.message);
    res.status(500).json({ error: 'Error al obtener empleados.' });
  }
});

// POST /api/empleados — agregar empleado a la tienda
router.post('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  const { nombre, cargo } = req.body;
  if (!nombre?.trim()) return res.status(400).json({ error: 'El nombre es obligatorio.' });
  try {
    const { data, error } = await supabase
      .from('empleados')
      .insert({
        tienda_id: req.usuario.id,
        nombre: nombre.trim(),
        cargo: cargo?.trim() || 'Asesor de Ventas',
        semana_asignada: 1,
        activo: true
      })
      .select('id, nombre, cargo')
      .single();
    if (error) throw error;
    await actualizarConteo(req.usuario.id);
    res.status(201).json({ empleado: data });
  } catch (err) {
    console.error('[Empleados POST]', err.message);
    res.status(500).json({ error: 'Error al agregar empleado.' });
  }
});

// PUT /api/empleados/:id — actualizar nombre o cargo
router.put('/:id', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  const { nombre, cargo } = req.body;
  if (!nombre?.trim()) return res.status(400).json({ error: 'El nombre es obligatorio.' });
  try {
    const { data: emp } = await supabase
      .from('empleados').select('tienda_id').eq('id', req.params.id).single();
    if (!emp || emp.tienda_id !== req.usuario.id) return res.status(403).json({ error: 'Sin permiso.' });
    const { data, error } = await supabase
      .from('empleados')
      .update({ nombre: nombre.trim(), cargo: cargo?.trim() || 'Asesor de Ventas' })
      .eq('id', req.params.id)
      .select('id, nombre, cargo').single();
    if (error) throw error;
    res.json({ empleado: data });
  } catch (err) {
    console.error('[Empleados PUT]', err.message);
    res.status(500).json({ error: 'Error al actualizar empleado.' });
  }
});

// DELETE /api/empleados/:id — desactivar empleado (soft delete)
router.delete('/:id', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  try {
    const { data: emp } = await supabase
      .from('empleados').select('tienda_id').eq('id', req.params.id).single();
    if (!emp || emp.tienda_id !== req.usuario.id) return res.status(403).json({ error: 'Sin permiso.' });
    await supabase.from('empleados').update({ activo: false }).eq('id', req.params.id);
    await actualizarConteo(req.usuario.id);
    res.json({ ok: true });
  } catch (err) {
    console.error('[Empleados DELETE]', err.message);
    res.status(500).json({ error: 'Error al desactivar empleado.' });
  }
});

// GET /api/empleados/admin/:tienda_id — admin ve empleados activos con estado 100% de la semana activa
router.get('/admin/:tienda_id', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Solo para admin.' });
  try {
    const { data: semana } = await supabase
      .from('semanas').select('id, numero').eq('activa', true).maybeSingle();

    const { data, error } = await supabase
      .from('empleados')
      .select('id, nombre, cargo, foto_url, espacios_album(desbloqueado, semana_id)')
      .eq('tienda_id', req.params.tienda_id)
      .eq('activo', true)
      .order('nombre');
    if (error) throw error;

    const empleados = (data || []).map(emp => {
      const espacio = semana
        ? (emp.espacios_album || []).find(e => e.semana_id === semana.id)
        : null;
      return {
        id: emp.id,
        nombre: emp.nombre,
        cargo: emp.cargo || 'Asesor de Ventas',
        foto_url: emp.foto_url || null,
        desbloqueado: espacio?.desbloqueado || false,
      };
    });

    res.json({
      empleados,
      semana: semana ? { id: semana.id, numero: semana.numero } : null,
      desbloqueados: empleados.filter(e => e.desbloqueado).length,
    });
  } catch (err) {
    console.error('[Empleados Admin GET]', err.message);
    res.status(500).json({ error: 'Error al obtener empleados.' });
  }
});

async function actualizarConteo(tiendaId) {
  try {
    const { count } = await supabase
      .from('empleados')
      .select('id', { count: 'exact', head: true })
      .eq('tienda_id', tiendaId)
      .eq('activo', true);
    await supabase.from('tiendas').update({ total_empleados: count || 0 }).eq('id', tiendaId);
  } catch (e) {
    console.error('[ConteoEmpleados]', e.message);
  }
}

module.exports = router;
