const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

/**
 * Creates the database if it doesn't exist, then runs the schema to
 * create all tables. Safe to call on every startup — uses IF NOT EXISTS.
 */
const initDatabase = async () => {
    // 1️⃣  Connect WITHOUT specifying a database so we can CREATE it
    let rootConn;
    try {
        rootConn = await mysql.createConnection({
            host: process.env.DB_HOST || 'localhost',
            port: parseInt(process.env.DB_PORT) || 3306,
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            multipleStatements: true, // needed to run the full schema at once
        });
    } catch (err) {
        console.error('❌ Cannot connect to MySQL server:', err.message);
        console.error('   ➤ Make sure MySQL is running and credentials in .env are correct.');
        process.exit(1);
    }

    // 2️⃣  Create the database if it doesn't already exist
    const dbName = process.env.DB_NAME || 'lifevora_db';
    try {
        await rootConn.query(
            `CREATE DATABASE IF NOT EXISTS \`${dbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`
        );
        console.log(`🗄️  Database "${dbName}" ready.`);
    } catch (err) {
        console.error('❌ Failed to create database:', err.message);
        await rootConn.end();
        process.exit(1);
    }

    // 3️⃣  Run the schema (all CREATE TABLE IF NOT EXISTS statements)
    const schemaPath = path.join(__dirname, '../../database/schema.sql');
    if (!fs.existsSync(schemaPath)) {
        console.warn('⚠️  No schema.sql found at', schemaPath, '— skipping table creation.');
        await rootConn.end();
        return;
    }

    // Strip the CREATE DATABASE / USE lines — we already handled those above
    let schema = fs.readFileSync(schemaPath, 'utf8');
    schema = schema
        .replace(/CREATE DATABASE.*?;/gis, '')   // remove CREATE DATABASE block
        .replace(/USE\s+\S+\s*;/gi, '')           // remove USE statement
        .trim();

    if (!schema) {
        console.warn('⚠️  schema.sql is empty after stripping DB statements.');
        await rootConn.end();
        return;
    }

    try {
        await rootConn.query(`USE \`${dbName}\``);
        await rootConn.query(schema);
        console.log('✅ All tables are up to date.');
    } catch (err) {
        console.error('❌ Failed to apply schema:', err.message);
        await rootConn.end();
        process.exit(1);
    }

    await rootConn.end();
};

module.exports = { initDatabase };
