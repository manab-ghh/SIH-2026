const { errorResponse } = require('../utils/response');
const logger = require('../utils/logger');

const notFound = (req, res, next) => {
  const error = new Error(`Route not found - ${req.originalUrl}`);
  res.status(404);
  next(error);
};

const errorHandler = (err, req, res, next) => {
  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  logger.error(`Error processing request: ${err.message}`, { stack: err.stack, path: req.originalUrl });

  // Handle Mongoose Bad ObjectId
  if (err.name === 'CastError' && err.kind === 'ObjectId') {
    return errorResponse(res, 'Resource not found: Invalid ID format', null, 404);
  }

  // Handle Mongoose duplicate key
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    return errorResponse(res, `Duplicate field value entered for ${field}`, null, 400);
  }

  // Handle Mongoose Validation Error
  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map((val) => val.message);
    return errorResponse(res, messages.join(', '), null, 400);
  }

  return errorResponse(
    res,
    err.message || 'Internal Server Error',
    process.env.NODE_ENV === 'development' ? err.stack : null,
    statusCode
  );
};

module.exports = { notFound, errorHandler };
