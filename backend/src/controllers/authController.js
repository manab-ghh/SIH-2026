const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * @desc    Register a new user
 * @route   POST /api/auth/register
 * @access  Public
 */
const register = async (req, res) => {
  try {
    const { name, phone, email, password, preferredLanguage, location, craftSpecialty } = req.body;

    const userExists = await User.findOne({ phone });
    if (userExists) {
      return errorResponse(res, 'An account with this phone number already exists', null, 400);
    }

    const user = await User.create({
      name,
      phone,
      email: email || '',
      password,
      preferredLanguage: preferredLanguage || 'hi',
      location: location || 'Varanasi, Uttar Pradesh, India',
      craftSpecialty: craftSpecialty || 'Handloom & Handicrafts',
      role: 'artisan',
    });

    const token = generateToken(user._id, user.role);

    return successResponse(
      res,
      'Registration successful',
      {
        user: {
          id: user._id,
          name: user.name,
          phone: user.phone,
          email: user.email,
          preferredLanguage: user.preferredLanguage,
          profileImage: user.profileImage,
          location: user.location,
          craftSpecialty: user.craftSpecialty,
          role: user.role,
        },
        token,
      },
      201
    );
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Login user with phone and password
 * @route   POST /api/auth/login
 * @access  Public
 */
const login = async (req, res) => {
  try {
    const { phone, password } = req.body;

    const user = await User.findOne({ phone }).select('+password');
    if (!user) {
      return errorResponse(res, 'Invalid phone number or password', null, 401);
    }

    const isMatch = await user.matchPassword(password);
    if (!isMatch) {
      return errorResponse(res, 'Invalid phone number or password', null, 401);
    }

    const token = generateToken(user._id, user.role);

    return successResponse(res, 'Login successful', {
      user: {
        id: user._id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        preferredLanguage: user.preferredLanguage,
        profileImage: user.profileImage,
        location: user.location,
        craftSpecialty: user.craftSpecialty,
        role: user.role,
      },
      token,
    });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Demo Artisan Quick Login
 * @route   POST /api/auth/demo-artisan
 * @access  Public
 */
const demoLogin = async (req, res) => {
  try {
    let demoUser = await User.findOne({ phone: '9876543210' });

    if (!demoUser) {
      demoUser = await User.create({
        name: 'Ramu Weaver',
        phone: '9876543210',
        email: 'ramu.artisan@shilpsetu.in',
        password: 'demoPassword123',
        preferredLanguage: 'hi',
        location: 'Varanasi Weavers Cluster, Uttar Pradesh',
        craftSpecialty: 'Chanderi & Banarasi Silk Weaving',
        profileImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=300',
        role: 'artisan',
      });
    }

    const token = generateToken(demoUser._id, demoUser.role);

    return successResponse(res, 'Logged in as Demo Artisan', {
      user: {
        id: demoUser._id,
        name: demoUser.name,
        phone: demoUser.phone,
        email: demoUser.email,
        preferredLanguage: demoUser.preferredLanguage,
        profileImage: demoUser.profileImage,
        location: demoUser.location,
        craftSpecialty: demoUser.craftSpecialty,
        role: demoUser.role,
      },
      token,
    });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Get Current Logged in User Profile
 * @route   GET /api/auth/me
 * @access  Private
 */
const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    return successResponse(res, 'Profile retrieved', { user });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Update Profile & Preferred Language
 * @route   PUT /api/auth/profile
 * @access  Private
 */
const updateProfile = async (req, res) => {
  try {
    const { name, email, preferredLanguage, location, craftSpecialty, profileImage } = req.body;

    const user = await User.findById(req.user._id);
    if (!user) {
      return errorResponse(res, 'User not found', null, 404);
    }

    if (name) user.name = name;
    if (email !== undefined) user.email = email;
    if (preferredLanguage) user.preferredLanguage = preferredLanguage;
    if (location) user.location = location;
    if (craftSpecialty) user.craftSpecialty = craftSpecialty;
    if (profileImage) user.profileImage = profileImage;

    await user.save();

    return successResponse(res, 'Profile updated successfully', { user });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

module.exports = {
  register,
  login,
  demoLogin,
  getMe,
  updateProfile,
};
