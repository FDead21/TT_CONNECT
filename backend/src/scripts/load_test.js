const io = require('socket.io-client');
const faker = require('faker');

const NUM_CLIENTS = 100;
const MESSAGES_PER_CLIENT = 10;
const SERVER_URL = 'http://localhost:3000';

async function runLoadTest() {
  console.log(`Starting load test with ${NUM_CLIENTS} clients...`);
  
  const clients = [];
  const rooms = ['room1', 'room2', 'room3'];
  
  // Create clients
  for (let i = 0; i < NUM_CLIENTS; i++) {
    const client = io(SERVER_URL, {
      auth: { token: 'test_token_' + i }
    });
    
    client.on('connect', () => {
      const roomId = rooms[i % rooms.length];
      client.emit('join_room', roomId);
    });
    
    client.on('new_message', (data) => {
      console.log(`Client ${i} received message: ${data.message.substring(0, 20)}...`);
    });
    
    clients.push({ client, id: i });
  }
  
  // Wait for all connections
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  // Send messages
  const startTime = Date.now();
  let messagesSent = 0;
  
  for (const clientInfo of clients) {
    const roomId = rooms[clientInfo.id % rooms.length];
    
    for (let j = 0; j < MESSAGES_PER_CLIENT; j++) {
      clientInfo.client.emit('send_message', {
        roomId,
        message: faker.lorem.sentence(),
        messageType: 'text'
      });
      messagesSent++;
    }
  }
  
  const endTime = Date.now();
  const duration = (endTime - startTime) / 1000;
  
  console.log(`Load test completed:`);
  console.log(`- Messages sent: ${messagesSent}`);
  console.log(`- Duration: ${duration}s`);
  console.log(`- Messages per second: ${(messagesSent / duration).toFixed(2)}`);
  
  // Cleanup
  clients.forEach(clientInfo => clientInfo.client.disconnect());
}

runLoadTest().catch(console.error);