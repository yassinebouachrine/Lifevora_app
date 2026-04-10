const express = require('express');
const cors = require('cors');
require('dotenv').config();

const { testConnection } = require('./src/config/database');
const { errorMiddleware, notFoundMiddleware } = require('./src/middleware/errorMiddleware');

const authRoutes = require('./src/routes/authRoutes');
const activityRoutes = require('./src/routes/activityRoutes');
const profileRoutes = require('./src/routes/profileRoutes');
const statsRoutes = require('./src/routes/statsRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Log en développement
if (process.env.NODE_ENV === 'development') {
    app.use((req, res, next) => {
        console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
        next();
    });
}

// Health check
app.get('/health', (req, res) => {
    res.json({
        success: true,
        message: '🏃 Lifevora API is running!',
        version: '1.0.0',
        timestamp: new Date().toISOString()
    });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/activities', activityRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/stats', statsRoutes);

// Erreurs
app.use(notFoundMiddleware);
app.use(errorMiddleware);

// Démarrage
const startServer = async () => {
    await testConnection();
    app.listen(PORT, '0.0.0.0', () => {
        console.log('');
        console.log('🚀 ================================');
        console.log(`🏃  Lifevora Backend démarré!`);
        console.log(`📡  Port     : ${PORT}`);
        console.log(`🌍  Local    : http://192.168.100.11:${PORT}`);
        console.log(`📱  Emulator : http://10.0.2.2:${PORT}`);
        console.log('🚀 ================================');
        console.log('');
    });
};

startServer();

module.exports = app;