const app = require('./app');
const connectDB = require('./config/db');
const env = require('./config/env');
const logger = require('./utils/logger');

// Connect to MongoDB
connectDB().then(() => {
  const server = app.listen(env.port, () => {
    logger.info(`✨ ShilpSetu AI Server running in ${env.nodeEnv} mode on port ${env.port}`);
    logger.info(`🚀 API Health Endpoint: http://localhost:${env.port}/api/health`);
  });

  // Handle Unhandled Promise Rejections
  process.on('unhandledRejection', (err) => {
    logger.error(`Unhandled Rejection: ${err.message}`);
    server.close(() => process.exit(1));
  });
});
