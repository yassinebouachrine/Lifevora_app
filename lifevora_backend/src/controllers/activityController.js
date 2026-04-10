const { v4: uuidv4 } = require('uuid');
const { pool } = require('../config/database');

// Calculer calories selon type/durée/intensité
const calculateCalories = (type, durationMin, intensity) => {
    const MET = {
        course:      { faible: 8,   modere: 10,  eleve: 13 },
        marche:      { faible: 3,   modere: 4,   eleve: 5  },
        velo:        { faible: 5,   modere: 8,   eleve: 11 },
        yoga:        { faible: 2.5, modere: 3,   eleve: 4  },
        natation:    { faible: 6,   modere: 8,   eleve: 10 },
        musculation: { faible: 4,   modere: 6,   eleve: 8  },
        autre:       { faible: 4,   modere: 5,   eleve: 7  },
    };
    const met = MET[type]?.[intensity] || 5;
    const weightKg = 70;
    return Math.round((met * weightKg * durationMin) / 60);
};

// ========================================
// GET /api/activities
// Query: type, page, limit, sort, order, search
// ========================================
const getActivities = async (req, res) => {
    try {
        const userId = req.user.id;
        const {
            type,
            page = 1,
            limit = 50,
            sort = 'date_iso',
            order = 'DESC',
            search
        } = req.query;

        let query = `
            SELECT id, user_id, type, duration_min, intensity, 
                   date_iso, note, calories_burned, created_at
            FROM activities
            WHERE user_id = ?
        `;
        const params = [userId];

        if (type && type !== 'tout') {
            query += ' AND type = ?';
            params.push(type);
        }

        if (search && search.trim()) {
            query += ' AND (note LIKE ? OR type LIKE ?)';
            const s = `%${search.trim()}%`;
            params.push(s, s);
        }

        const allowedSorts = ['date_iso', 'duration_min', 'calories_burned', 'created_at'];
        const sortField = allowedSorts.includes(sort) ? sort : 'date_iso';
        const sortOrder = order.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
        query += ` ORDER BY ${sortField} ${sortOrder}`;

        const offset = (parseInt(page) - 1) * parseInt(limit);
        query += ' LIMIT ? OFFSET ?';
        params.push(parseInt(limit), offset);

        const [rows] = await pool.execute(query, params);

        // Count total
        let countQuery = 'SELECT COUNT(*) as total FROM activities WHERE user_id = ?';
        const countParams = [userId];
        if (type && type !== 'tout') {
            countQuery += ' AND type = ?';
            countParams.push(type);
        }
        const [countRows] = await pool.execute(countQuery, countParams);

        // Mapper vers ActivityModel Flutter
        const activities = rows.map(a => ({
            id: a.id,
            userId: a.user_id,
            type: a.type,
            durationMin: a.duration_min,
            intensity: a.intensity,
            dateISO: a.date_iso,
            note: a.note,
            caloriesBurned: a.calories_burned
        }));

        res.status(200).json({
            success: true,
            data: {
                activities,
                total: countRows[0].total,
                page: parseInt(page),
                limit: parseInt(limit)
            }
        });

    } catch (error) {
        console.error('Erreur getActivities:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur lors de la récupération des activités'
        });
    }
};

// ========================================
// GET /api/activities/:id
// ========================================
const getActivityById = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const [rows] = await pool.execute(
            `SELECT id, user_id, type, duration_min, intensity,
                    date_iso, note, calories_burned, created_at
             FROM activities
             WHERE id = ? AND user_id = ?`,
            [id, userId]
        );

        if (rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Activité non trouvée'
            });
        }

        const a = rows[0];
        res.status(200).json({
            success: true,
            data: {
                activity: {
                    id: a.id,
                    userId: a.user_id,
                    type: a.type,
                    durationMin: a.duration_min,
                    intensity: a.intensity,
                    dateISO: a.date_iso,
                    note: a.note,
                    caloriesBurned: a.calories_burned
                }
            }
        });

    } catch (error) {
        console.error('Erreur getActivityById:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur serveur'
        });
    }
};

// ========================================
// POST /api/activities
// Body: { type, durationMin, intensity, dateISO, note? }
// ========================================
const createActivity = async (req, res) => {
    try {
        const userId = req.user.id;
        const { type, durationMin, intensity, dateISO, note } = req.body;

        // Validation
        if (!type || !durationMin || !dateISO) {
            return res.status(400).json({
                success: false,
                message: 'type, durationMin et dateISO sont requis'
            });
        }

        const validTypes = ['course', 'marche', 'velo', 'yoga', 'natation', 'musculation', 'autre'];
        if (!validTypes.includes(type)) {
            return res.status(400).json({
                success: false,
                message: `Type invalide. Valeurs acceptées: ${validTypes.join(', ')}`
            });
        }

        const validIntensities = ['faible', 'modere', 'eleve'];
        const safeIntensity = validIntensities.includes(intensity) ? intensity : 'modere';

        if (parseInt(durationMin) < 1 || parseInt(durationMin) > 1440) {
            return res.status(400).json({
                success: false,
                message: 'durationMin doit être entre 1 et 1440'
            });
        }

        const activityId = uuidv4();
        const calories = calculateCalories(type, parseInt(durationMin), safeIntensity);

        await pool.execute(
            `INSERT INTO activities (id, user_id, type, duration_min, intensity, date_iso, note, calories_burned)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                activityId,
                userId,
                type,
                parseInt(durationMin),
                safeIntensity,
                dateISO,
                note || null,
                calories
            ]
        );

        res.status(201).json({
            success: true,
            message: 'Activité ajoutée avec succès',
            data: {
                activity: {
                    id: activityId,
                    userId,
                    type,
                    durationMin: parseInt(durationMin),
                    intensity: safeIntensity,
                    dateISO,
                    note: note || null,
                    caloriesBurned: calories
                }
            }
        });

    } catch (error) {
        console.error('Erreur createActivity:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur lors de l\'ajout de l\'activité'
        });
    }
};

// ========================================
// PUT /api/activities/:id
// ========================================
const updateActivity = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;
        const { type, durationMin, intensity, dateISO, note } = req.body;

        const [existing] = await pool.execute(
            'SELECT id FROM activities WHERE id = ? AND user_id = ?',
            [id, userId]
        );

        if (existing.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Activité non trouvée'
            });
        }

        const calories = (type && durationMin && intensity)
            ? calculateCalories(type, parseInt(durationMin), intensity)
            : null;

        await pool.execute(
            `UPDATE activities SET
                type = COALESCE(?, type),
                duration_min = COALESCE(?, duration_min),
                intensity = COALESCE(?, intensity),
                date_iso = COALESCE(?, date_iso),
                note = COALESCE(?, note),
                calories_burned = COALESCE(?, calories_burned),
                updated_at = NOW()
             WHERE id = ? AND user_id = ?`,
            [type, durationMin, intensity, dateISO, note, calories, id, userId]
        );

        res.status(200).json({
            success: true,
            message: 'Activité modifiée avec succès'
        });

    } catch (error) {
        console.error('Erreur updateActivity:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur lors de la modification'
        });
    }
};

// ========================================
// DELETE /api/activities/:id
// ========================================
const deleteActivity = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const [result] = await pool.execute(
            'DELETE FROM activities WHERE id = ? AND user_id = ?',
            [id, userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Activité non trouvée'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Activité supprimée avec succès'
        });

    } catch (error) {
        console.error('Erreur deleteActivity:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur lors de la suppression'
        });
    }
};

module.exports = {
    getActivities,
    getActivityById,
    createActivity,
    updateActivity,
    deleteActivity
};