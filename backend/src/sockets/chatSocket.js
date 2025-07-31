const { Message, Room } = require('../models/chatModels');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const socketAuth = (socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    socket.userId = decoded.userId;
    next();
  } catch (err) {
    next(new Error('Authentication error'));
  }
};

const handleConnection = (io) => {
  io.use(socketAuth);
  
  io.on('connection', (socket) => {
    console.log(`User ${socket.userId} connected`);
    
    socket.on('join_room', async (roomId) => {
      try {
        socket.join(roomId);
        console.log(`User ${socket.userId} joined room ${roomId}`);
        
        // Load recent messages
        const messages = await Message.find({ roomId })
          .sort({ timestamp: -1 })
          .limit(50);
        
        socket.emit('room_messages', messages.reverse());
      } catch (error) {
        socket.emit('error', { message: 'Failed to join room' });
      }
    });

    socket.on('send_message', async (data) => {
      try {
        const { roomId, message, messageType = 'text' } = data;
        
        // Get sender info from Oracle (you'll need to implement this)
        const senderName = await getSenderName(socket.userId);
        
        const newMessage = new Message({
          messageId: uuidv4(),
          roomId,
          senderId: socket.userId,
          senderName,
          message,
          messageType,
          timestamp: new Date(),
          isRead: false
        });

        await newMessage.save();

        // Update room's last activity
        await Room.findOneAndUpdate(
          { roomId },
          { lastActivity: new Date() }
        );

        // Broadcast to all users in the room
        io.to(roomId).emit('new_message', {
          messageId: newMessage.messageId,
          roomId: newMessage.roomId,
          senderId: newMessage.senderId,
          senderName: newMessage.senderName,
          message: newMessage.message,
          messageType: newMessage.messageType,
          timestamp: newMessage.timestamp,
          isRead: newMessage.isRead
        });

      } catch (error) {
        console.error('Send message error:', error);
        socket.emit('error', { message: 'Failed to send message' });
      }
    });

    socket.on('typing_start', (roomId) => {
      socket.to(roomId).emit('user_typing', {
        userId: socket.userId,
        isTyping: true
      });
    });

    socket.on('typing_stop', (roomId) => {
      socket.to(roomId).emit('user_typing', {
        userId: socket.userId,
        isTyping: false
      });
    });

    socket.on('disconnect', () => {
      console.log(`User ${socket.userId} disconnected`);
    });
  });
};

// Helper function to get sender name from Oracle
async function getSenderName(userId) {
  const oracledb = require('oracledb');
  let connection;
  
  try {
    connection = await oracledb.getConnection();
    const result = await connection.execute(
      `SELECT first_name, last_name FROM users WHERE user_id = :userId`,
      { userId }
    );
    
    if (result.rows.length > 0) {
      return `${result.rows[0][0]} ${result.rows[0][1]}`;
    }
    return 'Unknown User';
  } catch (error) {
    console.error('Error getting sender name:', error);
    return 'Unknown User';
  } finally {
    if (connection) {
      try { await connection.close(); } catch (err) { console.error(err); }
    }
  }
}

module.exports = { handleConnection };