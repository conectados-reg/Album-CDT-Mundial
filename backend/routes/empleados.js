const router = require('express').Router();
const { verificarToken } = require('./auth');
const db = require('../db');

// GET /api/empleados — empleados activos de la tienda autenticada
router.get('/', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  try {
    const empleados = await db.all(
      'SELECT id, nombre, cargo, foto_url, created_at FROM empleados WHERE tienda_id = $1 AND activo = true ORDER BY nombre',
      [req.usuario.id]
    );
    res.json({ empleados });
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
    const empleado = await db.one(
      `INSERT INTO empleados (tienda_id, nombre, cargo, semana_asignada, activo)
       VALUES ($1, $2, $3, 1, true)
       RETURNING id, nombre, cargo`,
      [req.usuario.id, nombre.trim(), cargo?.trim() || 'Asesor de Ventas']
    );
    await actualizarConteo(req.usuario.id);
    res.status(201).json({ empleado });
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
    const emp = await db.one('SELECT tienda_id FROM empleados WHERE id = $1', [req.params.id]);
    if (!emp || emp.tienda_id !== req.usuario.id) return res.status(403).json({ error: 'Sin permiso.' });

    const empleado = await db.one(
      `UPDATE empleados SET nombre = $1, cargo = $2 WHERE id = $3 RETURNING id, nombre, cargo`,
      [nombre.trim(), cargo?.trim() || 'Asesor de Ventas', req.params.id]
    );
    res.json({ empleado });
  } catch (err) {
    console.error('[Empleados PUT]', err.message);
    res.status(500).json({ error: 'Error al actualizar empleado.' });
  }
});

// DELETE /api/empleados/:id — desactivar empleado (soft delete)
router.delete('/:id', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'tienda') return res.status(403).json({ error: 'Solo para sucursales.' });
  try {
    const emp = await db.one('SELECT tienda_id FROM empleados WHERE id = $1', [req.params.id]);
    if (!emp || emp.tienda_id !== req.usuario.id) return res.status(403).json({ error: 'Sin permiso.' });

    await db.query('UPDATE empleados SET activo = false WHERE id = $1', [req.params.id]);
    await actualizarConteo(req.usuario.id);
    res.json({ ok: true });
  } catch (err) {
    console.error('[Empleados DELETE]', err.message);
    res.status(500).json({ error: 'Error al desactivar empleado.' });
  }
});

// GET /api/empleados/admin/:tienda_id — admin ve empleados con estado de desbloqueo semana activa
router.get('/admin/:tienda_id', verificarToken, async (req, res) => {
  if (req.usuario.rol !== 'admin') return res.status(403).json({ error: 'Solo para admin.' });
  try {
    const semana = await db.one('SELECT id, numero FROM semanas WHERE activa = true LIMIT 1');
    const semanaId = semana?.id || null;

    let empleados;
    if (semanaId) {
      empleados = await db.all(
        `SELECT e.id, e.nombre, e.cargo, e.foto_url,
                COALESCE(ea.desbloqueado, false) AS desbloqueado
         FROM empleados e
         LEFT JOIN espacios_album ea ON ea.empleado_id = e.id AND ea.semana_id = $2
         WHERE e.tienda_id = $1 AND e.activo = true
         ORDER BY e.nombre`,
        [req.params.tienda_id, semanaId]
      );
    } else {
      empleados = await db.all(
        `SELECT id, nombre, cargo, foto_url, false AS desbloqueado
         FROM empleados WHERE tienda_id = $1 AND activo = true ORDER BY nombre`,
        [req.params.tienda_id]
      );
    }

    const formateados = empleados.map(e => ({
      id:           e.id,
      nombre:       e.nombre,
      cargo:        e.cargo || 'Asesor de Ventas',
      foto_url:     e.foto_url || null,
      desbloqueado: e.desbloqueado,
    }));

    res.json({
      empleados:    formateados,
      semana:       semana ? { id: semana.id, numero: semana.numero } : null,
      desbloqueados: formateados.filter(e => e.desbloqueado).length,
    });
  } catch (err) {
    console.error('[Empleados Admin GET]', err.message);
    res.status(500).json({ error: 'Error al obtener empleados.' });
  }
});

async function actualizarConteo(tiendaId) {
  try {
    const { rows } = await db.query(
      'SELECT COUNT(*)::int AS cnt FROM empleados WHERE tienda_id = $1 AND activo = true',
      [tiendaId]
    );
    await db.query('UPDATE tiendas SET total_empleados = $1 WHERE id = $2', [rows[0].cnt, tiendaId]);
  } catch (e) {
    console.error('[ConteoEmpleados]', e.message);
  }
}

module.exports = router;
