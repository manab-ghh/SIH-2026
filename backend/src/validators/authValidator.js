const Joi = require('joi');

const registerSchema = Joi.object({
  name: Joi.string().trim().min(2).max(60).required(),
  phone: Joi.string().trim().min(8).max(15).required(),
  email: Joi.string().email().allow('').optional(),
  password: Joi.string().min(6).required(),
  preferredLanguage: Joi.string().valid('en', 'hi', 'bn', 'ta', 'te', 'mr').default('hi'),
  location: Joi.string().allow('').optional(),
  craftSpecialty: Joi.string().allow('').optional(),
});

const loginSchema = Joi.object({
  phone: Joi.string().trim().required(),
  password: Joi.string().required(),
});

const validateRegister = (req, res, next) => {
  const { error } = registerSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ success: false, message: error.details[0].message });
  }
  next();
};

const validateLogin = (req, res, next) => {
  const { error } = loginSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ success: false, message: error.details[0].message });
  }
  next();
};

module.exports = {
  validateRegister,
  validateLogin,
};
