const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// CORS totalmente abierto para evitar bloqueos con Vercel
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// Ruta de diagnóstico para saber si Render está vivo
app.get('/', (req, res) => {
  res.send('¡Backend del Álbum Sportline corriendo en vivo! 🚀');
});

// ENRUTAMIENTO (Forzado en minúsculas estrictas para Linux/Render)
app.use('/api/auth', require('./routes/auth'));
app.use('/api/tiendas', require('./routes/stores'));

// Manejo de rutas globales no encontradas
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada en el backend.' });
});

app.listen(PORT, () => {
  console.log(`Servidor activo en el puerto ${PORT}`);
});
