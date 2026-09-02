const Joi = require('joi');

const productCreateSchema = Joi.object({
  name: Joi.string().trim().required(),
  description: Joi.string().allow('').optional(),
  descriptionHindi: Joi.string().allow('').optional(),
  descriptionEnglish: Joi.string().allow('').optional(),
  images: Joi.array().items(Joi.string()).default([]),
  category: Joi.string()
    .valid('Textile', 'Pottery', 'Jewelry', 'Woodwork', 'Metalware', 'Painting', 'Leatherwork', 'BambooCane', 'Other')
    .default('Textile'),
  material: Joi.string().allow('').optional(),
  craftType: Joi.string().allow('').optional(),
  color: Joi.string().allow('').optional(),
  size: Joi.string().allow('').optional().default('Medium'),
  quantity: Joi.number().min(0).default(1),
  rawMaterialCost: Joi.number().min(0).default(0),
  productionCost: Joi.number().min(0).default(0),
  otherCost: Joi.number().min(0).default(0),
  totalCost: Joi.number().min(0).default(0),
  recommendedPrice: Joi.number().min(0).default(0),
  minimumPrice: Joi.number().min(0).default(0),
  competitivePrice: Joi.number().min(0).default(0),
  premiumPrice: Joi.number().min(0).default(0),
  keywords: Joi.array().items(Joi.string()).default([]),
  craftStory: Joi.string().allow('').optional(),
  status: Joi.string().valid('draft', 'ready', 'published', 'out_of_stock').default('draft'),
});

const validateProduct = (req, res, next) => {
  const { error } = productCreateSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ success: false, message: error.details[0].message });
  }
  next();
};

module.exports = {
  validateProduct,
};
