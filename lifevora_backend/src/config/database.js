const mysql = require('mysql2/promise');
require('dotenv').config();

// Pool is created lazily so it is only instantiated AFTER initDatabase()
// has ensured the database and tables exist.
let _pool = null;

const getPool = () => {
    if (!_pool) {
        _pool = mysql.createPool({
            host:     process.env.DB_HOST     || 'localhost',
            port:     parseInt(process.env.DB_PORT) || 3306,
            user:     process.env.DB_USER     || 'root',
            password: process.env.DB_PASSWORD || '',
            database: process.env.DB_NAME     || 'lifevora_db',
            waitForConnections: true,
            connectionLimit: 10,
            queueLimit: 0,
            charset: 'utf8mb4',
            timezone: '+00:00',
        });
    }
    return _pool;
};

const testConnection = async () => {
    try {
        const connection = await getPool().getConnection();
        console.log('✅ MySQL connecté → Base: ' + (process.env.DB_NAME || 'lifevora_db'));
        connection.release();
    } catch (error) {
        console.error('❌ Erreur MySQL:', error.message);
        process.exit(1);
    }
};

// Keep `pool` as a named export for backwards compatibility with any file
// that does `const { pool } = require('./database')`.
// It is a Proxy so callers always get the live pool instance.
const pool = new Proxy({}, {
    get(_target, prop) {
        return getPool()[prop];
    },
});

module.exports = { pool, getPool, testConnection };