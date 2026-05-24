const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración de CORS para Vercel
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// Verificación inicial
app.get('/', (req, res) => {
  res.send('Servidor del Álbum CDT Mundial Activo y Corriendo 🚀');
});

// ENRUTAMIENTO UNIFICADO (Corregido para apuntar a stores.js)
app.use('/api/auth', require('./routes/auth'));
app.use('/api/tiendas', require('./routes/stores'));

// Control de errores de rutas globales
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada en el backend.' });
});

app.listen(PORT, () => {
  console.log(`Servidor escuchando en el puerto ${PORT}`);
});
