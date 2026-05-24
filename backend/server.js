const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración de CORS abierta para conectar con Vercel
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json({ limit: '10mb' }));

// Diagnóstico inicial
app.get('/', (req, res) => {
  res.send('¡Servidor del Álbum Sportline operando con éxito! 🚀');
});

app.use('/api/auth', require('./routes/auth.js'));
app.use('/api/tiendas', require('./routes/stores.js'));
app.use('/api/album', require('./routes/album.js'));
app.use('/api/empleados', require('./routes/empleados.js'));
app.use('/api/ventas', require('./routes/ventas.js'));
app.use('/api/notificaciones', require('./routes/notificaciones.js'));

// Control de rutas globales no encontradas
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada en el backend.' });
});

app.listen(PORT, () => {
  console.log(`Servidor activo en el puerto ${PORT}`);
});
