const express = require('express');
const { createPost, getFeed, toggleLike } = require('../controllers/postController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Route to get the main feed
// GET /api/posts/feed
router.get('/feed', authenticateToken, getFeed);

// Route to create a new post
// POST /api/posts
router.post('/', authenticateToken, createPost);

// Route to like or unlike a post
// POST /api/posts/:postId/like
router.post('/:postId/like', authenticateToken, toggleLike);

module.exports = router;
