const express = require('express');
const router = express.Router();
const foodController = require('../controllers/foodController');
const authMiddleware = require('../middleware/auth.middleware');

router.get('/scan/:barcode', authMiddleware, foodController.scanBarcode);

module.exports = router;