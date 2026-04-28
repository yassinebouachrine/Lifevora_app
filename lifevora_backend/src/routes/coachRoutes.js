const express = require('express');
const router = express.Router();
const { chatWithCoach, checkCoachHealth } = require('../controllers/coachController');
const authMiddleware = require('../middleware/authMiddleware'); // ← Sans { }

// ─── Route publique pour vérifier le service Gemini ─────
router.get('/health', checkCoachHealth);

// ─── Route protégée pour chatter avec le coach ──────────
router.post('/chat', authMiddleware, chatWithCoach);

module.exports = router;