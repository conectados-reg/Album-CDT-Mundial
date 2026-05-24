const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración de CORS para permitir que Vercel se conecte sin bloqueos
app.use(cors({
  origin: '*', // Permite peticiones desde cualquier sitio (ideal para producción con Vercel)
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Middleware para entender formatos JSON
app.use(express.json());

// Ruta base de prueba para verificar que el servidor está vivo
app.get('/', (req, res) => {
  res.send('Servidor del Álbum CDT Mundial corriendo exitosamente 🚀');
});

// Enrutamiento principal del sistema
app.use('/api/auth', require('./routes/auth'));
app.use('/api/tiendas', require('./routes/tiendas'));

// Manejo de rutas inexistentes (Error 404)
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada en el servidor de Render.' });
});

// Iniciar el servidor en el puerto correcto
app.listen(PORT, () => {
  console.log(`Servidor activo en el puerto ${PORT}`);
});
