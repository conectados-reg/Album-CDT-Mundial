const express    = require('express');
const cors       = require('cors');
const cookieParser = require('cookie-parser');
require('dotenv').config();

const app  = express();
const PORT = process.env.PORT || 3000;

const ALLOWED_ORIGINS = [
  process.env.FRONTEND_URL,
  'https://album-cdt-mundial.vercel.app',
].filter(Boolean);

app.use(cors({
  origin: (origin, cb) => {
    // Allow requests with no origin (server-to-server, Postman, etc.)
    if (!origin || ALLOWED_ORIGINS.includes(origin)) return cb(null, true);
    cb(null, true); // permissive — actual auth is via signed JWT
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-sync-key'],
}));

app.use(cookieParser());
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
app.use('/api/semanas', require('./routes/semanas.js'));
app.use('/api/notificaciones', require('./routes/notificaciones.js'));
app.use('/api/sync', require('./routes/sync.js'));
app.use('/api/seed', require('./routes/seed.js'));
app.use('/api/ranking', require('./routes/ranking.js'));

// Control de rutas globales no encontradas
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada en el backend.' });
});

app.listen(PORT, () => {
  console.log(`Servidor activo en el puerto ${PORT}`);
});
