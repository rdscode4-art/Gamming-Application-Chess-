require('dotenv').config();
const http = require('http');
const app = require('./app');
app.set('trust proxy', 1);
const connectDB = require('./config/db');
const logger = require('./config/logger');
const initSocket = require('./socket/socketManager');
const ClockManager = require('./jobs/clockManager');

const PORT = process.env.PORT || 3000;
const server = http.createServer(app);

const startServer = async () => {
  try {
    await connectDB();

    const io = initSocket(server);
    
    // Start clock manager
    const clockManager = new ClockManager(io);
    clockManager.start();

    server.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Server is successfully running on port ${PORT} (0.0.0.0)`);
      logger.info(`Server running in ${process.env.NODE_ENV} mode on port ${PORT} (0.0.0.0)`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
