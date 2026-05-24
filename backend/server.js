const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración de CORS segura y flexible para Vercel
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// Verificación inicial del servidor
app.get('/', (req, res) => {
  res.send('Servidor del Álbum CDT Mundial Activo y Corriendo 🚀');
});

// Enrutamiento unificado para Auth, Tiendas e Index
app.use('/api/auth', require('./routes/auth'));
app.use('/api/tiendas', require('./routes/tiendas'));

// Control de errores de rutas globales
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada en el backend.' });
});

app.listen(PORT, () => {
  console.log(`Servidor escuchando en el puerto ${PORT}`);
});
