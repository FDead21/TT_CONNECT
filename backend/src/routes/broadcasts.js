const express = require('express');
const { sendBroadcast, getBroadcasts } = require('../controllers/broadcastController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Route to get all broadcasts for the logged-in user
// GET /api/broadcasts
router.get('/', authenticateToken, getBroadcasts);

// Route to send a new broadcast message
// POST /api/broadcasts
router.post('/', authenticateToken, sendBroadcast);

module.exports = router;
