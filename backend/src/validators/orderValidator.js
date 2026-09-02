const Joi = require('joi');

const orderCreateSchema = Joi.object({
  productId: Joi.string().required(),
  quantity: Joi.number().min(1).default(1),
  buyerName: Joi.string().trim().default('Pooja Sharma'),
  buyerPhone: Joi.string().trim().default('+91 98765 43210'),
  shippingAddress: Joi.object({
    street: Joi.string().allow('').default('42, Heritage Park, MG Road'),
    city: Joi.string().allow('').default('Bengaluru'),
    state: Joi.string().allow('').default('Karnataka'),
    postalCode: Joi.string().allow('').default('560001'),
    country: Joi.string().allow('').default('India'),
  }).optional(),
});

const validateOrder = (req, res, next) => {
  const { error } = orderCreateSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ success: false, message: error.details[0].message });
  }
  next();
};

module.exports = {
  validateOrder,
};
