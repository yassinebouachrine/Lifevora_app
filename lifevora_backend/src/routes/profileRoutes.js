const express = require('express');
const router = express.Router();
const {
    getProfile,
    updateProfile,
    completeOnboarding,
    changePassword
} = require('../controllers/profileController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/', getProfile);
router.put('/', updateProfile);
router.post('/complete-onboarding', completeOnboarding);
router.put('/change-password', changePassword);

module.exports = router;