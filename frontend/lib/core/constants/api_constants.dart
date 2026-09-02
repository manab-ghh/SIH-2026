import 'package:flutter/foundation.dart';

class ApiConstants {
  // Base URL resolution
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    // For Android physical or emulator
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Use 10.0.2.2 for Android Studio Emulator, or 127.0.0.1 for desktop/web
        return 'http://10.0.2.2:8000/api';
      default:
        return 'http://127.0.0.1:8000/api';
    }
  }

  // Host URL for serving static image uploads
  static String get hostUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String demoLogin = '/auth/demo-artisan';
  static const String me = '/auth/me';
  static const String profile = '/auth/profile';

  // Products
  static const String products = '/products';
  static const String productStats = '/products/stats/summary';

  // AI Services
  static const String imageEnhance = '/ai/image-enhance';
  static const String catalogGenerate = '/ai/catalog';
  static const String pricingGenerate = '/ai/pricing';
  static const String voiceProcess = '/ai/voice';

  // Orders
  static const String orders = '/orders';

  // Search
  static const String visualSearch = '/search/visual';

  // Marketplace
  static const String marketplacePublish = '/marketplace/publish';
  static const String marketplaceListings = '/marketplace/listings';
}
