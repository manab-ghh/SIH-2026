const express = require('express');
const router = express.Router();
const {
  getOrders,
  getOrderById,
  createOrder,
  updateOrderStatus,
} = require('../controllers/orderController');
const { protect } = require('../middleware/authMiddleware');
const { validateOrder } = require('../validators/orderValidator');

router.get('/', protect, getOrders);
router.get('/:id', protect, getOrderById);
router.post('/', protect, validateOrder, createOrder);
router.patch('/:id/status', protect, updateOrderStatus);

module.exports = router;
