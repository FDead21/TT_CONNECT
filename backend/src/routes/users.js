const express = require('express');
const { getUserProfile } = require('../controllers/userController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Route to get a user's profile by their employee ID
// GET /api/users/:empId
router.get('/:empId', authenticateToken, getUserProfile);

module.exports = router;
