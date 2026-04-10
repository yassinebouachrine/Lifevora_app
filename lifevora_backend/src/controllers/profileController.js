const { pool } = require('../config/database');
const bcrypt = require('bcryptjs');

// ========================================
// GET /api/profile
// ========================================
const getProfile = async (req, res) => {
    try {
        const userId = req.user.id;

        const [rows] = await pool.execute(
            `SELECT u.id, u.name, u.email, u.age,
                    u.goal_minutes_per_week, u.avatar_state, u.created_at,
                    up.gender, up.weight, up.height, up.fitness_goal,
                    up.activity_level, up.notifications_enabled,
                    up.theme_mode, up.onboarding_completed
             FROM users u
             LEFT JOIN user_profiles up ON u.id = up.user_id
             WHERE u.id = ?`,
            [userId]
        );

        if (rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Profil non trouvé'
            });
        }

        const [stats] = await pool.execute(
            `SELECT
                COUNT(*) as totalActivities,
                COALESCE(SUM(duration_min), 0) as totalMinutes,
                COALESCE(SUM(calories_burned), 0) as totalCalories
             FROM activities WHERE user_id = ?`,
            [userId]
        );

        const u = rows[0];
        res.status(200).json({
            success: true,
            data: {
                user: {
                    id: u.id,
                    name: u.name,
                    email: u.email,
                    age: u.age,
                    goalMinutesPerWeek: u.goal_minutes_per_week,
                    avatarState: u.avatar_state || 'neutral',
                    memberSince: u.created_at
                },
                profile: {
                    gender: u.gender,
                    weight: u.weight,
                    height: u.height,
                    fitnessGoal: u.fitness_goal,
                    activityLevel: u.activity_level,
                    notificationsEnabled: u.notifications_enabled !== false,
                    themeMode: u.theme_mode || 'system',
                    onboardingCompleted: u.onboarding_completed || false
                },
                stats: {
                    totalActivities: parseInt(stats[0].totalActivities),
                    totalMinutes: parseInt(stats[0].totalMinutes),
                    totalCalories: parseInt(stats[0].totalCalories)
                }
            }
        });

    } catch (error) {
        console.error('Erreur getProfile:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur serveur'
        });
    }
};

// ========================================
// PUT /api/profile
// Body: { name?, age?, goalMinutesPerWeek?, avatarState?, ... }
// ========================================
const updateProfile = async (req, res) => {
    const connection = await pool.getConnection();
    try {
        const userId = req.user.id;
        const {
            name, age, goalMinutesPerWeek, avatarState,
            gender, weight, height, fitnessGoal,
            activityLevel, notificationsEnabled, themeMode
        } = req.body;

        await connection.beginTransaction();

        // Mise à jour table users
        if (name || age || goalMinutesPerWeek || avatarState) {
            await connection.execute(
                `UPDATE users SET
                    name = COALESCE(?, name),
                    age = COALESCE(?, age),
                    goal_minutes_per_week = COALESCE(?, goal_minutes_per_week),
                    avatar_state = COALESCE(?, avatar_state),
                    updated_at = NOW()
                 WHERE id = ?`,
                [name, age, goalMinutesPerWeek, avatarState, userId]
            );
        }

        // Mise à jour table user_profiles
        await connection.execute(
            `UPDATE user_profiles SET
                gender = COALESCE(?, gender),
                weight = COALESCE(?, weight),
                height = COALESCE(?, height),
                fitness_goal = COALESCE(?, fitness_goal),
                activity_level = COALESCE(?, activity_level),
                notifications_enabled = COALESCE(?, notifications_enabled),
                theme_mode = COALESCE(?, theme_mode),
                updated_at = NOW()
             WHERE user_id = ?`,
            [gender, weight, height, fitnessGoal, activityLevel,
             notificationsEnabled, themeMode, userId]
        );

        await connection.commit();

        res.status(200).json({
            success: true,
            message: 'Profil mis à jour avec succès'
        });

    } catch (error) {
        await connection.rollback();
        console.error('Erreur updateProfile:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur lors de la mise à jour'
        });
    } finally {
        connection.release();
    }
};

// ========================================
// POST /api/profile/complete-onboarding
// ========================================
const completeOnboarding = async (req, res) => {
    const connection = await pool.getConnection();
    try {
        const userId = req.user.id;
        const {
            age, gender, weight, height,
            fitnessGoal, activityLevel, goalMinutesPerWeek
        } = req.body;

        await connection.beginTransaction();

        // Mettre à jour age et objectif dans users
        await connection.execute(
            `UPDATE users SET age = COALESCE(?, age),
             goal_minutes_per_week = COALESCE(?, goal_minutes_per_week),
             updated_at = NOW() WHERE id = ?`,
            [age, goalMinutesPerWeek || 150, userId]
        );

        // Mettre à jour profil
        await connection.execute(
            `UPDATE user_profiles SET
                gender = COALESCE(?, gender),
                weight = COALESCE(?, weight),
                height = COALESCE(?, height),
                fitness_goal = COALESCE(?, fitness_goal),
                activity_level = COALESCE(?, activity_level),
                onboarding_completed = TRUE,
                updated_at = NOW()
             WHERE user_id = ?`,
            [gender, weight, height, fitnessGoal, activityLevel, userId]
        );

        await connection.commit();

        res.status(200).json({
            success: true,
            message: 'Onboarding complété!'
        });

    } catch (error) {
        await connection.rollback();
        console.error('Erreur completeOnboarding:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur serveur'
        });
    } finally {
        connection.release();
    }
};

// ========================================
// PUT /api/profile/change-password
// ========================================
const changePassword = async (req, res) => {
    try {
        const userId = req.user.id;
        const { currentPassword, newPassword } = req.body;

        if (!currentPassword || !newPassword) {
            return res.status(400).json({
                success: false,
                message: 'currentPassword et newPassword requis'
            });
        }

        if (newPassword.length < 6) {
            return res.status(400).json({
                success: false,
                message: 'Le nouveau mot de passe doit contenir au moins 6 caractères'
            });
        }

        const [users] = await pool.execute(
            'SELECT password FROM users WHERE id = ?',
            [userId]
        );

        const isValid = await bcrypt.compare(currentPassword, users[0].password);
        if (!isValid) {
            return res.status(400).json({
                success: false,
                message: 'Mot de passe actuel incorrect'
            });
        }

        const hashed = await bcrypt.hash(newPassword, 12);
        await pool.execute(
            'UPDATE users SET password = ?, updated_at = NOW() WHERE id = ?',
            [hashed, userId]
        );

        res.status(200).json({
            success: true,
            message: 'Mot de passe modifié avec succès'
        });

    } catch (error) {
        console.error('Erreur changePassword:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur serveur'
        });
    }
};

module.exports = { getProfile, updateProfile, completeOnboarding, changePassword };