const express = require('express');
const router = express.Router();
const {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
  getStatsSummary,
} = require('../controllers/productController');
const { protect } = require('../middleware/authMiddleware');
const { validateProduct } = require('../validators/productValidator');

router.get('/stats/summary', protect, getStatsSummary);
router.get('/', protect, getProducts);
router.get('/:id', protect, getProductById);
router.post('/', protect, validateProduct, createProduct);
router.put('/:id', protect, updateProduct);
router.delete('/:id', protect, deleteProduct);

module.exports = router;
