const jwt = require('jsonwebtoken');
const User = require('../models/User');
const env = require('../config/env');
const { errorResponse } = require('../utils/response');

const protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, env.jwtSecret);
      req.user = await User.findById(decoded.id).select('-password');

      if (!req.user) {
        return errorResponse(res, 'User no longer exists', null, 401);
      }

      return next();
    } catch (error) {
      return errorResponse(res, 'Not authorized, token failed or expired', error.message, 401);
    }
  }

  if (!token) {
    return errorResponse(res, 'Not authorized, please provide an authentication token', null, 401);
  }
};

module.exports = { protect };
