const request = require('supertest');
const app = require('../server');

describe('Authentication API', () => {
  let authToken;

  test('Should login with valid credentials', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@company.com',
        password: 'password123'
      });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('token');
    expect(response.body).toHaveProperty('user');
    authToken = response.body.token;
  });

  test('Should reject invalid credentials', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@company.com',
        password: 'wrongpassword'
      });

    expect(response.status).toBe(401);
  });

  test('Should get user profile with valid token', async () => {
    const response = await request(app)
      .get('/api/users/profile')
      .set('Authorization', `Bearer ${authToken}`);

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('userId');
    expect(response.body).toHaveProperty('email');
  });
});

describe('Posts API', () => {
  let authToken;

  beforeAll(async () => {
    const loginResponse = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@company.com',
        password: 'password123'
      });
    authToken = loginResponse.body.token;
  });

  test('Should create a new post', async () => {
    const response = await request(app)
      .post('/api/posts')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        content: 'This is a test post'
      });

    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('postId');
    expect(response.body.content).toBe('This is a test post');
  });

  test('Should get feed posts', async () => {
    const response = await request(app)
      .get('/api/posts/feed')
      .set('Authorization', `Bearer ${authToken}`);

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('posts');
    expect(Array.isArray(response.body.posts)).toBe(true);
  });
});