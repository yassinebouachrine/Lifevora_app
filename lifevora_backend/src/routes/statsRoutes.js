const express = require('express');
const router = express.Router();
const { getDashboardStats, getWeeklyStats } = require('../controllers/statsController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/dashboard', getDashboardStats);
router.get('/weekly', getWeeklyStats);

module.exports = router;