const express = require('express');
const cors = require('cors');
require('dotenv').config();

const { testConnection } = require('./src/config/database');
const { initDatabase } = require('./src/config/initDatabase');
const { errorMiddleware, notFoundMiddleware } = require('./src/middleware/errorMiddleware');

const authRoutes = require('./src/routes/authRoutes');
const activityRoutes = require('./src/routes/activityRoutes');
const profileRoutes = require('./src/routes/profileRoutes');
const statsRoutes = require('./src/routes/statsRoutes');
const coachRoutes = require('./src/routes/coachRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

if (process.env.NODE_ENV === 'development') {
  app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
  });
}

app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: '🏃 Lifevora API is running!',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/activities', activityRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/stats', statsRoutes);
app.use('/api/coach', coachRoutes);

app.use(notFoundMiddleware);
app.use(errorMiddleware);

const os = require('os');

function getLocalIp() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (
        iface.family === 'IPv4' &&
        !iface.internal &&
        iface.address.startsWith('192.168.')
      ) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

const startServer = async () => {
  try {
    await initDatabase();
    await testConnection();

    const localIp = getLocalIp();

    app.listen(PORT, '0.0.0.0', () => {
      console.log('');
      console.log('🚀 ================================');
      console.log(`🏃  Lifevora Backend démarré!`);
      console.log(`📡  Port     : ${PORT}`);
      console.log(`🌍  Local    : http://${localIp}:${PORT}`);
      console.log(`🤖  Coach IA  : http://${localIp}:${PORT}/api/coach/health`);
      console.log('🚀 ================================');
      console.log('');
    });
  } catch (error) {
    console.error('❌ Erreur au démarrage du serveur:', error.message);
    process.exit(1);
  }
};

startServer();

module.exports = app;