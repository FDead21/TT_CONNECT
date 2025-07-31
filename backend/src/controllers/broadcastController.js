const oracledb = require('oracledb');

const sendBroadcast = async (req, res) => {
  let connection;
  try {
    const { title, message, targetAudience } = req.body;
    const senderId = req.userId;
    
    connection = await oracledb.getConnection();
    
    // Insert broadcast message
    const result = await connection.execute(
      `INSERT INTO broadcasts (broadcast_id, sender_id, title, message, 
                              target_audience, created_at)
       VALUES (broadcasts_seq.NEXTVAL, :senderId, :title, :message, 
               :targetAudience, SYSDATE)
       RETURNING broadcast_id INTO :broadcastId`,
      {
        senderId,
        title,
        message,
        targetAudience: JSON.stringify(targetAudience),
        broadcastId: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER }
      },
      { autoCommit: true }
    );

    const broadcastId = result.outBinds.broadcastId[0];
    
    // Get target users based on audience criteria
    let targetUsers = [];
    if (targetAudience.type === 'all') {
      const usersResult = await connection.execute(
        `SELECT user_id FROM users WHERE user_id != :senderId`,
        { senderId }
      );
      targetUsers = usersResult.rows.map(row => row[0]);
    } else if (targetAudience.type === 'department') {
      const usersResult = await connection.execute(
        `SELECT user_id FROM users 
         WHERE department = :department AND user_id != :senderId`,
        { department: targetAudience.department, senderId }
      );
      targetUsers = usersResult.rows.map(row => row[0]);
    }

    // Create broadcast recipients
    if (targetUsers.length > 0) {
      const recipients = targetUsers.map(userId => 
        `(broadcast_recipients_seq.NEXTVAL, ${broadcastId}, ${userId}, SYSDATE, 0)`
      ).join(',');
      
      await connection.execute(
        `INSERT INTO broadcast_recipients (recipient_id, broadcast_id, user_id, sent_at, is_read)
         VALUES ${recipients}`,
        [],
        { autoCommit: true }
      );
    }

    res.status(201).json({
      broadcastId,
      title,
      message,
      targetCount: targetUsers.length,
      createdAt: new Date()
    });
  } catch (error) {
    console.error('Send broadcast error:', error);
    res.status(500).json({ message: 'Server error' });
  } finally {
    if (connection) {
      try { await connection.close(); } catch (err) { console.error(err); }
    }
  }
};

const getBroadcasts = async (req, res) => {
  let connection;
  try {
    const userId = req.userId;
    
    connection = await oracledb.getConnection();
    const result = await connection.execute(
      `SELECT b.broadcast_id, b.title, b.message, b.created_at,
              u.first_name, u.last_name, br.is_read
       FROM broadcasts b
       JOIN users u ON b.sender_id = u.user_id
       JOIN broadcast_recipients br ON b.broadcast_id = br.broadcast_id
       WHERE br.user_id = :userId
       ORDER BY b.created_at DESC`,
      { userId }
    );

    const broadcasts = result.rows.map(row => ({
      broadcastId: row[0],
      title: row[1],
      message: row[2],
      createdAt: row[3],
      sender: {
        firstName: row[4],
        lastName: row[5]
      },
      isRead: row[6] === 1
    }));

    res.json(broadcasts);
  } catch (error) {
    console.error('Get broadcasts error:', error);
    res.status(500).json({ message: 'Server error' });
  } finally {
    if (connection) {
      try { await connection.close(); } catch (err) { console.error(err); }
    }
  }
};

module.exports = { sendBroadcast, getBroadcasts };