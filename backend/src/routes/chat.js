const express = require('express');
const { Room, Message } = require('../models/chatModels');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

// Get user's chat rooms
router.get('/rooms', authenticateToken, async (req, res) => {
  try {
    const userId = req.userId;
    
    const rooms = await Room.find({
      'participants.userId': userId
    }).sort({ lastActivity: -1 });

    res.json(rooms);
  } catch (error) {
    console.error('Get rooms error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get messages for a room
router.get('/rooms/:roomId/messages', authenticateToken, async (req, res) => {
  try {
    const { roomId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const skip = (page - 1) * limit;

    const messages = await Message.find({ roomId })
      .sort({ timestamp: -1 })
      .skip(skip)
      .limit(limit);

    res.json({
      messages: messages.reverse(),
      page,
      hasMore: messages.length === limit
    });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Create a new room
router.post('/rooms', authenticateToken, async (req, res) => {
  try {
    const { roomName, roomType = 'group', participantIds = [] } = req.body;
    const creatorId = req.userId;

    const roomId = `room_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    const participants = [
      { userId: creatorId, role: 'admin' },
      ...participantIds.map(id => ({ userId: id, role: 'member' }))
    ];

    const newRoom = new Room({
      roomId,
      roomName,
      roomType,
      participants,
      createdBy: creatorId,
      createdAt: new Date(),
      lastActivity: new Date()
    });

    await newRoom.save();
    res.status(201).json(newRoom);
  } catch (error) {
    console.error('Create room error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;