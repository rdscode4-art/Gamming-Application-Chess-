const redis = require('redis');
const client = redis.createClient({ url: process.env.REDIS_URL || 'redis://localhost:6379' });

async function flush() {
  await client.connect();
  await client.flushAll();
  console.log('Redis flushed successfully!');
  await client.quit();
}

flush().catch(console.error);
