const Order = require('../models/Order');
const Product = require('../models/Product');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * @desc    Get all orders for the artisan
 * @route   GET /api/orders
 * @access  Private
 */
const getOrders = async (req, res) => {
  try {
    const { status } = req.query;
    const query = { artisanId: req.user._id };

    if (status && status !== 'all') {
      query.status = status;
    }

    const orders = await Order.find(query).populate('productId').sort({ createdAt: -1 });

    return successResponse(res, 'Orders retrieved successfully', {
      count: orders.length,
      orders,
    });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Get order details by ID
 * @route   GET /api/orders/:id
 * @access  Private
 */
const getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id).populate('productId');
    if (!order) {
      return errorResponse(res, 'Order not found', null, 404);
    }
    return successResponse(res, 'Order details retrieved', { order });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Create a new order (buyer simulation / demo)
 * @route   POST /api/orders
 * @access  Private
 */
const createOrder = async (req, res) => {
  try {
    const { productId, quantity = 1, buyerName, buyerPhone, shippingAddress } = req.body;

    const product = await Product.findById(productId);
    if (!product) {
      return errorResponse(res, 'Product not found', null, 404);
    }

    const price = product.recommendedPrice || 1500;
    const totalAmount = price * quantity;
    const orderNumber = `SHL-${Math.floor(10000 + Math.random() * 90000)}`;

    const order = await Order.create({
      orderNumber,
      productId: product._id,
      productSnapshot: {
        name: product.name,
        image: product.images[0] || '',
        category: product.category,
        craftType: product.craftType,
      },
      artisanId: product.artisanId,
      buyerId: req.user._id,
      buyerName: buyerName || 'Pooja Sharma',
      buyerPhone: buyerPhone || '+91 98765 43210',
      quantity,
      price,
      totalAmount,
      status: 'pending',
      shippingAddress: shippingAddress || {
        street: '42, Heritage Park, MG Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560001',
        country: 'India',
      },
      timeline: [
        {
          status: 'pending',
          message: 'Order placed by buyer and awaiting artisan confirmation',
          timestamp: new Date(),
        },
      ],
    });

    return successResponse(res, 'Order created successfully', { order }, 201);
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Update Order Status & Append to Timeline
 * @route   PATCH /api/orders/:id/status
 * @access  Private
 */
const updateOrderStatus = async (req, res) => {
  try {
    const { status, note } = req.body;
    const validStatuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];

    if (!validStatuses.includes(status)) {
      return errorResponse(res, `Invalid status. Must be one of: ${validStatuses.join(', ')}`, null, 400);
    }

    const order = await Order.findById(req.params.id);
    if (!order) {
      return errorResponse(res, 'Order not found', null, 404);
    }

    order.status = status;

    const statusMessages = {
      pending: 'Order is pending confirmation',
      confirmed: 'Order confirmed by artisan',
      processing: 'Handcrafting & packaging in progress',
      shipped: 'Handed over to craft logistics courier',
      delivered: 'Package successfully delivered to buyer',
      cancelled: 'Order has been cancelled',
    };

    order.timeline.push({
      status,
      message: note || statusMessages[status] || `Status updated to ${status}`,
      timestamp: new Date(),
    });

    await order.save();

    return successResponse(res, `Order status updated to ${status}`, { order });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

module.exports = {
  getOrders,
  getOrderById,
  createOrder,
  updateOrderStatus,
};
