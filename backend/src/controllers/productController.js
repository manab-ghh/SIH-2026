const Product = require('../models/Product');
const Order = require('../models/Order');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * @desc    Get all products (with status filters, search, pagination)
 * @route   GET /api/products
 * @access  Private
 */
const getProducts = async (req, res) => {
  try {
    const { status, category, search, sort } = req.query;
    const query = { artisanId: req.user._id };

    if (status && status !== 'all') {
      query.status = status;
    }

    if (category && category !== 'All') {
      query.category = category;
    }

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { craftType: { $regex: search, $options: 'i' } },
        { material: { $regex: search, $options: 'i' } },
      ];
    }

    let sortOptions = { createdAt: -1 };
    if (sort === 'price_asc') sortOptions = { recommendedPrice: 1 };
    if (sort === 'price_desc') sortOptions = { recommendedPrice: -1 };

    const products = await Product.find(query).sort(sortOptions);

    return successResponse(res, 'Products retrieved successfully', {
      count: products.length,
      products,
    });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Get single product by ID
 * @route   GET /api/products/:id
 * @access  Private
 */
const getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return errorResponse(res, 'Product not found', null, 404);
    }
    return successResponse(res, 'Product retrieved', { product });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Create new Product
 * @route   POST /api/products
 * @access  Private
 */
const createProduct = async (req, res) => {
  try {
    const body = {
      ...req.body,
      artisanId: req.user._id,
    };

    // Calculate totalCost if not explicitly given
    if (!body.totalCost) {
      body.totalCost =
        (Number(body.rawMaterialCost) || 0) +
        (Number(body.productionCost) || 0) +
        (Number(body.otherCost) || 0);
    }

    const product = await Product.create(body);

    return successResponse(res, 'Product created successfully', { product }, 201);
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Update Product
 * @route   PUT /api/products/:id
 * @access  Private
 */
const updateProduct = async (req, res) => {
  try {
    let product = await Product.findById(req.params.id);
    if (!product) {
      return errorResponse(res, 'Product not found', null, 404);
    }

    // Verify ownership
    if (product.artisanId.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return errorResponse(res, 'Not authorized to update this product', null, 403);
    }

    const updateData = { ...req.body };
    if (
      updateData.rawMaterialCost !== undefined ||
      updateData.productionCost !== undefined ||
      updateData.otherCost !== undefined
    ) {
      updateData.totalCost =
        (Number(updateData.rawMaterialCost ?? product.rawMaterialCost) || 0) +
        (Number(updateData.productionCost ?? product.productionCost) || 0) +
        (Number(updateData.otherCost ?? product.otherCost) || 0);
    }

    product = await Product.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
      runValidators: true,
    });

    return successResponse(res, 'Product updated successfully', { product });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Delete Product
 * @route   DELETE /api/products/:id
 * @access  Private
 */
const deleteProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return errorResponse(res, 'Product not found', null, 404);
    }

    if (product.artisanId.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return errorResponse(res, 'Not authorized to delete this product', null, 403);
    }

    await Product.findByIdAndDelete(req.params.id);

    return successResponse(res, 'Product deleted successfully', null);
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Get Artisan Analytics & Dashboard Stats
 * @route   GET /api/products/stats/summary
 * @access  Private
 */
const getStatsSummary = async (req, res) => {
  try {
    const artisanId = req.user._id;

    const totalProducts = await Product.countDocuments({ artisanId });
    const publishedProducts = await Product.countDocuments({ artisanId, status: 'published' });
    const draftProducts = await Product.countDocuments({ artisanId, status: 'draft' });
    const outOfStockProducts = await Product.countDocuments({ artisanId, status: 'out_of_stock' });

    const orders = await Order.find({ artisanId });
    const totalOrders = orders.length;
    const totalSales = orders.reduce((sum, ord) => sum + (ord.totalAmount || 0), 0);

    const recentProducts = await Product.find({ artisanId }).sort({ createdAt: -1 }).limit(5);

    return successResponse(res, 'Dashboard analytics retrieved', {
      stats: {
        totalProducts,
        publishedProducts,
        draftProducts,
        outOfStockProducts,
        totalOrders,
        totalSales,
        estimatedEarnings: Math.round(totalSales * 0.92), // net artisan payout
      },
      recentProducts,
    });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

module.exports = {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
  getStatsSummary,
};
