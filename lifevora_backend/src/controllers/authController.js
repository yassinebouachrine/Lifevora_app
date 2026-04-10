const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { pool } = require('../config/database');

// Générer JWT
const generateToken = (userId) => {
    return jwt.sign(
        { userId },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRE || '30d' }
    );
};

// ========================================
// POST /api/auth/register
// Body: { name, email, password, age? }
// ========================================
const register = async (req, res) => {
    const connection = await pool.getConnection();
    try {
        const { name, email, password, age } = req.body;

        // Validation
        if (!name || !email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Nom, email et mot de passe sont requis'
            });
        }

        if (password.length < 6) {
            return res.status(400).json({
                success: false,
                message: 'Le mot de passe doit contenir au moins 6 caractères'
            });
        }

        await connection.beginTransaction();

        // Vérifier email existant
        const [existing] = await connection.execute(
            'SELECT id FROM users WHERE email = ?',
            [email.toLowerCase().trim()]
        );

        if (existing.length > 0) {
            await connection.rollback();
            return res.status(409).json({
                success: false,
                message: 'Cet email est déjà utilisé'
            });
        }

        const hashedPassword = await bcrypt.hash(password, 12);
        const userId = uuidv4();

        // Créer utilisateur
        await connection.execute(
            `INSERT INTO users (id, name, email, password, age, goal_minutes_per_week, avatar_state)
             VALUES (?, ?, ?, ?, ?, 150, 'neutral')`,
            [userId, name.trim(), email.toLowerCase().trim(), hashedPassword, age || 25]
        );

        // Créer profil par défaut
        await connection.execute(
            `INSERT INTO user_profiles (user_id, onboarding_completed)
             VALUES (?, FALSE)`,
            [userId]
        );

        await connection.commit();

        const token = generateToken(userId);

        // Réponse adaptée au UserModel Flutter
        res.status(201).json({
            success: true,
            message: 'Compte créé avec succès',
            data: {
                token,
                user: {
                    id: userId,
                    name: name.trim(),
                    email: email.toLowerCase().trim(),
                    age: age || 25,
                    goalMinutesPerWeek: 150,
                    avatarState: 'neutral'
                }
            }
        });

    } catch (error) {
        await connection.rollback();
        console.error('Erreur register:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur lors de la création du compte'
        });
    } finally {
        connection.release();
    }
};

// ========================================
// POST /api/auth/login
// Body: { email, password }
// ========================================
const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Email et mot de passe requis'
            });
        }

        // Récupérer utilisateur + profil
        const [users] = await pool.execute(
            `SELECT u.id, u.name, u.email, u.password, u.age,
                    u.goal_minutes_per_week, u.avatar_state,
                    up.onboarding_completed, up.theme_mode,
                    up.notifications_enabled
             FROM users u
             LEFT JOIN user_profiles up ON u.id = up.user_id
             WHERE u.email = ?`,
            [email.toLowerCase().trim()]
        );

        if (users.length === 0) {
            return res.status(401).json({
                success: false,
                message: 'Email ou mot de passe incorrect'
            });
        }

        const user = users[0];

        const isValid = await bcrypt.compare(password, user.password);
        if (!isValid) {
            return res.status(401).json({
                success: false,
                message: 'Email ou mot de passe incorrect'
            });
        }

        const token = generateToken(user.id);

        // Réponse adaptée au UserModel Flutter
        res.status(200).json({
            success: true,
            message: 'Connexion réussie',
            data: {
                token,
                user: {
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    age: user.age,
                    goalMinutesPerWeek: user.goal_minutes_per_week,
                    avatarState: user.avatar_state || 'neutral'
                },
                settings: {
                    onboarding_completed: user.onboarding_completed || false,
                    theme_mode: user.theme_mode || 'system',
                    notifications_enabled: user.notifications_enabled !== false
                }
            }
        });

    } catch (error) {
        console.error('Erreur login:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur serveur'
        });
    }
};

// ========================================
// GET /api/auth/me
// ========================================
const getMe = async (req, res) => {
    try {
        const [users] = await pool.execute(
            `SELECT u.id, u.name, u.email, u.age,
                    u.goal_minutes_per_week, u.avatar_state, u.created_at,
                    up.onboarding_completed, up.theme_mode,
                    up.gender, up.weight, up.height,
                    up.fitness_goal, up.notifications_enabled
             FROM users u
             LEFT JOIN user_profiles up ON u.id = up.user_id
             WHERE u.id = ?`,
            [req.user.id]
        );

        if (users.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Utilisateur non trouvé'
            });
        }

        const u = users[0];

        res.status(200).json({
            success: true,
            data: {
                user: {
                    id: u.id,
                    name: u.name,
                    email: u.email,
                    age: u.age,
                    goalMinutesPerWeek: u.goal_minutes_per_week,
                    avatarState: u.avatar_state || 'neutral'
                },
                settings: {
                    onboarding_completed: u.onboarding_completed || false,
                    theme_mode: u.theme_mode || 'system',
                    notifications_enabled: u.notifications_enabled !== false,
                    gender: u.gender,
                    weight: u.weight,
                    height: u.height,
                    fitness_goal: u.fitness_goal
                }
            }
        });

    } catch (error) {
        console.error('Erreur getMe:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur serveur'
        });
    }
};

// ========================================
// POST /api/auth/logout
// ========================================
const logout = async (req, res) => {
    try {
        await pool.execute(
            'DELETE FROM refresh_tokens WHERE user_id = ?',
            [req.user.id]
        );
        res.status(200).json({
            success: true,
            message: 'Déconnexion réussie'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Erreur serveur'
        });
    }
};

// ========================================
// POST /api/auth/forgot-password
// ========================================
const forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({
                success: false,
                message: 'Email requis'
            });
        }

        // Toujours retourner succès pour la sécurité
        res.status(200).json({
            success: true,
            message: 'Si cet email existe, un lien a été envoyé'
        });

        const [users] = await pool.execute(
            'SELECT id FROM users WHERE email = ?',
            [email.toLowerCase()]
        );
        if (users.length === 0) return;

        // TODO: Envoyer email de réinitialisation
        const token = uuidv4();
        const expiresAt = new Date(Date.now() + 3600000);
        await pool.execute(
            'INSERT INTO password_resets (email, token, expires_at) VALUES (?, ?, ?)',
            [email.toLowerCase(), token, expiresAt]
        );

    } catch (error) {
        console.error('Erreur forgotPassword:', error);
    }
};

module.exports = { register, login, getMe, logout, forgotPassword };