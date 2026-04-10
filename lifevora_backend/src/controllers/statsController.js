const { pool } = require('../config/database');

// ========================================
// GET /api/stats/dashboard
// ========================================
const getDashboardStats = async (req, res) => {
    try {
        const userId = req.user.id;

        // Stats semaine courante
        const [weekStats] = await pool.execute(
            `SELECT
                COALESCE(SUM(duration_min), 0) as week_minutes,
                COUNT(*) as week_sessions
             FROM activities
             WHERE user_id = ?
             AND date_iso >= DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY)
             AND date_iso <= CURDATE()`,
            [userId]
        );

        // Stats mois courant
        const [monthStats] = await pool.execute(
            `SELECT
                COALESCE(SUM(duration_min), 0) as month_minutes,
                COUNT(*) as month_sessions
             FROM activities
             WHERE user_id = ?
             AND MONTH(date_iso) = MONTH(CURDATE())
             AND YEAR(date_iso) = YEAR(CURDATE())`,
            [userId]
        );

        // Durée moyenne (30 derniers jours)
        const [avgStats] = await pool.execute(
            `SELECT COALESCE(AVG(duration_min), 0) as avg_duration
             FROM activities
             WHERE user_id = ?
             AND date_iso >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)`,
            [userId]
        );

        // Objectif utilisateur
        const weekMinutes = parseInt(weekStats[0].week_minutes);
        const goalMinutes = req.user.goal_minutes_per_week || 150;
        const progressPercent = Math.min(
            Math.round((weekMinutes / goalMinutes) * 100),
            100
        );

        // Données graphique 7 derniers jours
        const [chartData] = await pool.execute(
            `SELECT
                date_iso as date,
                COALESCE(SUM(duration_min), 0) as total_minutes,
                COUNT(*) as sessions
             FROM activities
             WHERE user_id = ?
             AND date_iso >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
             GROUP BY date_iso
             ORDER BY date_iso ASC`,
            [userId]
        );

        res.status(200).json({
            success: true,
            data: {
                weekly: {
                    minutes: weekMinutes,
                    sessions: parseInt(weekStats[0].week_sessions),
                    goalMinutes: goalMinutes,
                    progressPercent,
                    remainingMinutes: Math.max(goalMinutes - weekMinutes, 0)
                },
                monthly: {
                    minutes: parseInt(monthStats[0].month_minutes),
                    sessions: parseInt(monthStats[0].month_sessions)
                },
                average: {
                    durationMin: Math.round(parseFloat(avgStats[0].avg_duration))
                },
                chartData
            }
        });

    } catch (error) {
        console.error('Erreur getDashboardStats:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur lors de la récupération des statistiques'
        });
    }
};

// ========================================
// GET /api/stats/weekly?weeks=4
// ========================================
const getWeeklyStats = async (req, res) => {
    try {
        const userId = req.user.id;
        const { weeks = 4 } = req.query;

        const [data] = await pool.execute(
            `SELECT
                YEAR(date_iso) as year,
                WEEK(date_iso, 1) as week,
                SUM(duration_min) as total_minutes,
                COUNT(*) as sessions,
                ROUND(AVG(duration_min)) as avg_duration,
                MIN(date_iso) as week_start
             FROM activities
             WHERE user_id = ?
             AND date_iso >= DATE_SUB(CURDATE(), INTERVAL ? WEEK)
             GROUP BY YEAR(date_iso), WEEK(date_iso, 1)
             ORDER BY week_start DESC`,
            [userId, parseInt(weeks)]
        );

        res.status(200).json({
            success: true,
            data: { weeklyStats: data }
        });

    } catch (error) {
        console.error('Erreur getWeeklyStats:', error);
        res.status(500).json({
            success: false,
            message: 'Erreur serveur'
        });
    }
};

module.exports = { getDashboardStats, getWeeklyStats };