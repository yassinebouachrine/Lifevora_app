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
// Body: { name?, age?, goalMinutesPerWeek?, avatarState?,
//         gender?, weight?, height?, fitnessGoal?,
//         activityLevel?, notificationsEnabled?, themeMode? }
// ========================================
const updateProfile = async (req, res) => {
    const connection = await pool.getConnection();
    try {
        const userId = req.user.id;
        const {
            name,
            age,
            goalMinutesPerWeek,
            avatarState,
            gender,
            weight,
            height,
            fitnessGoal,
            activityLevel,
            notificationsEnabled,
            themeMode
        } = req.body;

        // Validation
        if (age !== undefined) {
            const ageNum = parseInt(age);
            if (isNaN(ageNum) || ageNum < 10 || ageNum > 100) {
                return res.status(400).json({
                    success: false,
                    message: 'Âge invalide (10-100)'
                });
            }
        }

        if (goalMinutesPerWeek !== undefined) {
            const goalNum = parseInt(goalMinutesPerWeek);
            if (isNaN(goalNum) || goalNum < 30 || goalNum > 1440) {
                return res.status(400).json({
                    success: false,
                    message: 'Objectif invalide (30-1440 minutes)'
                });
            }
        }

        await connection.beginTransaction();

        // ✅ Mise à jour table users
        const userUpdates = [];
        const userValues = [];

        if (name !== undefined && name !== null) {
            userUpdates.push('name = ?');
            userValues.push(name.trim());
        }
        if (age !== undefined && age !== null) {
            userUpdates.push('age = ?');
            userValues.push(parseInt(age));
        }
        if (goalMinutesPerWeek !== undefined && goalMinutesPerWeek !== null) {
            userUpdates.push('goal_minutes_per_week = ?');
            userValues.push(parseInt(goalMinutesPerWeek));
        }
        if (avatarState !== undefined && avatarState !== null) {
            userUpdates.push('avatar_state = ?');
            userValues.push(avatarState);
        }

        if (userUpdates.length > 0) {
            userUpdates.push('updated_at = NOW()');
            userValues.push(userId);
            await connection.execute(
                `UPDATE users SET ${userUpdates.join(', ')} WHERE id = ?`,
                userValues
            );
        }

        // ✅ Mise à jour table user_profiles
        const profileUpdates = [];
        const profileValues = [];

        if (gender !== undefined && gender !== null) {
            profileUpdates.push('gender = ?');
            profileValues.push(gender);
        }
        if (weight !== undefined && weight !== null) {
            profileUpdates.push('weight = ?');
            profileValues.push(parseFloat(weight));
        }
        if (height !== undefined && height !== null) {
            profileUpdates.push('height = ?');
            profileValues.push(parseFloat(height));
        }
        if (fitnessGoal !== undefined && fitnessGoal !== null) {
            profileUpdates.push('fitness_goal = ?');
            profileValues.push(fitnessGoal);
        }
        if (activityLevel !== undefined && activityLevel !== null) {
            profileUpdates.push('activity_level = ?');
            profileValues.push(activityLevel);
        }
        if (notificationsEnabled !== undefined && notificationsEnabled !== null) {
            profileUpdates.push('notifications_enabled = ?');
            profileValues.push(notificationsEnabled ? 1 : 0);
        }
        if (themeMode !== undefined && themeMode !== null) {
            profileUpdates.push('theme_mode = ?');
            profileValues.push(themeMode);
        }

        if (profileUpdates.length > 0) {
            profileUpdates.push('updated_at = NOW()');
            profileValues.push(userId);
            await connection.execute(
                `UPDATE user_profiles SET ${profileUpdates.join(', ')} WHERE user_id = ?`,
                profileValues
            );
        }

        await connection.commit();

        // ✅ Retourner les données mises à jour
        const [updated] = await connection.execute(
            `SELECT u.id, u.name, u.email, u.age,
                    u.goal_minutes_per_week, u.avatar_state,
                    up.notifications_enabled, up.theme_mode
             FROM users u
             LEFT JOIN user_profiles up ON u.id = up.user_id
             WHERE u.id = ?`,
            [userId]
        );

        const u = updated[0];
        res.status(200).json({
            success: true,
            message: 'Profil mis à jour avec succès',
            data: {
                user: {
                    id: u.id,
                    name: u.name,
                    email: u.email,
                    age: u.age,
                    goalMinutesPerWeek: u.goal_minutes_per_week,
                    avatarState: u.avatar_state || 'neutral'
                }
            }
        });

    } catch (error) {
        await connection.rollback();
        console.error('Erreur updateProfile:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur lors de la mise à jour du profil'
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
            age,
            gender,
            weight,
            height,
            fitnessGoal,
            activityLevel,
            goalMinutesPerWeek
        } = req.body;

        await connection.beginTransaction();

        await connection.execute(
            `UPDATE users SET
                age = COALESCE(?, age),
                goal_minutes_per_week = COALESCE(?, goal_minutes_per_week),
                updated_at = NOW()
             WHERE id = ?`,
            [age || null, goalMinutesPerWeek || 150, userId]
        );

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
            [
                gender || null,
                weight || null,
                height || null,
                fitnessGoal || null,
                activityLevel || null,
                userId
            ]
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
// Body: { currentPassword, newPassword }
// ========================================
const changePassword = async (req, res) => {
    try {
        const userId = req.user.id;
        const { currentPassword, newPassword } = req.body;

        // Validation
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

        if (currentPassword === newPassword) {
            return res.status(400).json({
                success: false,
                message: 'Le nouveau mot de passe doit être différent de l\'ancien'
            });
        }

        // Vérifier mot de passe actuel
        const [users] = await pool.execute(
            'SELECT password FROM users WHERE id = ?',
            [userId]
        );

        if (users.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Utilisateur non trouvé'
            });
        }

        const isValid = await bcrypt.compare(currentPassword, users[0].password);
        if (!isValid) {
            return res.status(400).json({
                success: false,
                message: 'Mot de passe actuel incorrect'
            });
        }

        // Hasher et sauvegarder
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

module.exports = {
    getProfile,
    updateProfile,
    completeOnboarding,
    changePassword
};