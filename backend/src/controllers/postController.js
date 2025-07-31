const oracledb = require('oracledb');

const createPost = async (req, res) => {
  let connection;
  try {
    const { content, imageUrl } = req.body;
    const userId = req.userId;
    
    connection = await oracledb.getConnection();
    const result = await connection.execute(
      `INSERT INTO posts (post_id, user_id, content, image_url, created_at)
       VALUES (posts_seq.NEXTVAL, :userId, :content, :imageUrl, SYSDATE)
       RETURNING post_id INTO :postId`,
      {
        userId,
        content,
        imageUrl: imageUrl || null,
        postId: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER }
      },
      { autoCommit: true }
    );

    const postId = result.outBinds.postId[0];
    
    // Get the created post with user info
    const postResult = await connection.execute(
      `SELECT p.post_id, p.content, p.image_url, p.created_at,
              u.first_name, u.last_name, u.profile_image_url
       FROM posts p 
       JOIN users u ON p.user_id = u.user_id 
       WHERE p.post_id = :postId`,
      { postId }
    );

    const post = {
      postId: postResult.rows[0][0],
      content: postResult.rows[0][1],
      imageUrl: postResult.rows[0][2],
      createdAt: postResult.rows[0][3],
      author: {
        firstName: postResult.rows[0][4],
        lastName: postResult.rows[0][5],
        profileImageUrl: postResult.rows[0][6]
      },
      likesCount: 0,
      commentsCount: 0,
      isLiked: false
    };

    res.status(201).json(post);
  } catch (error) {
    console.error('Create post error:', error);
    res.status(500).json({ message: 'Server error' });
  } finally {
    if (connection) {
      try { await connection.close(); } catch (err) { console.error(err); }
    }
  }
};

const getFeed = async (req, res) => {
  let connection;
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const userId = req.userId;
    
    connection = await oracledb.getConnection();
    const result = await connection.execute(
      `SELECT p.post_id, p.content, p.image_url, p.created_at,
              u.user_id, u.first_name, u.last_name, u.profile_image_url,
              COUNT(l.like_id) as likes_count,
              COUNT(c.comment_id) as comments_count,
              CASE WHEN ul.like_id IS NOT NULL THEN 1 ELSE 0 END as is_liked
       FROM posts p
       JOIN users u ON p.user_id = u.user_id
       LEFT JOIN likes l ON p.post_id = l.post_id
       LEFT JOIN comments c ON p.post_id = c.post_id
       LEFT JOIN likes ul ON p.post_id = ul.post_id AND ul.user_id = :userId
       GROUP BY p.post_id, p.content, p.image_url, p.created_at,
                u.user_id, u.first_name, u.last_name, u.profile_image_url,
                ul.like_id
       ORDER BY p.created_at DESC
       OFFSET :offset ROWS FETCH NEXT :limit ROWS ONLY`,
      { userId, offset, limit }
    );

    const posts = result.rows.map(row => ({
      postId: row[0],
      content: row[1],
      imageUrl: row[2],
      createdAt: row[3],
      author: {
        userId: row[4],
        firstName: row[5],
        lastName: row[6],
        profileImageUrl: row[7]
      },
      likesCount: row[8],
      commentsCount: row[9],
      isLiked: row[10] === 1
    }));

    res.json({ posts, page, hasMore: posts.length === limit });
  } catch (error) {
    console.error('Get feed error:', error);
    res.status(500).json({ message: 'Server error' });
  } finally {
    if (connection) {
      try { await connection.close(); } catch (err) { console.error(err); }
    }
  }
};

const toggleLike = async (req, res) => {
  let connection;
  try {
    const postId = req.params.postId;
    const userId = req.userId;
    
    connection = await oracledb.getConnection();
    
    // Check if already liked
    const checkResult = await connection.execute(
      `SELECT like_id FROM likes WHERE post_id = :postId AND user_id = :userId`,
      { postId, userId }
    );

    if (checkResult.rows.length > 0) {
      // Unlike
      await connection.execute(
        `DELETE FROM likes WHERE post_id = :postId AND user_id = :userId`,
        { postId, userId },
        { autoCommit: true }
      );
      res.json({ liked: false });
    } else {
      // Like
      await connection.execute(
        `INSERT INTO likes (like_id, post_id, user_id, created_at)
         VALUES (likes_seq.NEXTVAL, :postId, :userId, SYSDATE)`,
        { postId, userId },
        { autoCommit: true }
      );
      res.json({ liked: true });
    }
  } catch (error) {
    console.error('Toggle like error:', error);
    res.status(500).json({ message: 'Server error' });
  } finally {
    if (connection) {
      try { await connection.close(); } catch (err) { console.error(err); }
    }
  }
};

module.exports = { createPost, getFeed, toggleLike };