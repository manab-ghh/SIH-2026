import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'mock_seed_data.dart';

class MockDatabase {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal();

  static const String _keyProducts = 'shilpsetu_mock_products_v1';
  static const String _keyOrders = 'shilpsetu_mock_orders_v1';
  static const String _keyListings = 'shilpsetu_mock_listings_v1';
  static const String _keyUser = 'shilpsetu_mock_user_v1';

  bool _isInitialized = false;

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _listings = [];
  Map<String, dynamic> _user = {};

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();

    // Products
    final productsJson = prefs.getString(_keyProducts);
    if (productsJson != null && productsJson.isNotEmpty) {
      try {
        final list = jsonDecode(productsJson) as List<dynamic>;
        _products =
            list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {
        _products =
            List<Map<String, dynamic>>.from(MockSeedData.initialProducts);
      }
    } else {
      _products = List<Map<String, dynamic>>.from(MockSeedData.initialProducts);
      await _saveProducts();
    }

    // Orders
    final ordersJson = prefs.getString(_keyOrders);
    if (ordersJson != null && ordersJson.isNotEmpty) {
      try {
        final list = jsonDecode(ordersJson) as List<dynamic>;
        _orders = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {
        _orders = List<Map<String, dynamic>>.from(MockSeedData.initialOrders);
      }
    } else {
      _orders = List<Map<String, dynamic>>.from(MockSeedData.initialOrders);
      await _saveOrders();
    }

    // Listings
    final listingsJson = prefs.getString(_keyListings);
    if (listingsJson != null && listingsJson.isNotEmpty) {
      try {
        final list = jsonDecode(listingsJson) as List<dynamic>;
        _listings =
            list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {
        _listings = List<Map<String, dynamic>>.from(
            MockSeedData.initialMarketplaceListings);
      }
    } else {
      _listings = List<Map<String, dynamic>>.from(
          MockSeedData.initialMarketplaceListings);
      await _saveListings();
    }

    // User
    final userJson = prefs.getString(_keyUser);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        _user = Map<String, dynamic>.from(jsonDecode(userJson) as Map);
      } catch (_) {
        _user = Map<String, dynamic>.from(MockSeedData.defaultUser);
      }
    } else {
      _user = Map<String, dynamic>.from(MockSeedData.defaultUser);
      await _saveUser();
    }

    _isInitialized = true;
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProducts, jsonEncode(_products));
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOrders, jsonEncode(_orders));
  }

  Future<void> _saveListings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyListings, jsonEncode(_listings));
  }

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(_user));
  }

  // --------------------------------------------------------------------------
  // PRODUCTS
  // --------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getProducts({
    String? status,
    String? category,
    String? search,
  }) async {
    await ensureInitialized();
    var list = List<Map<String, dynamic>>.from(_products);

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      final s = status.toLowerCase();
      list = list.where((p) {
        final prodStatus = (p['status'] ?? '').toString().toLowerCase();
        if (s == 'draft' || s == 'drafts') return prodStatus == 'draft';
        if (s == 'published') return prodStatus == 'published';
        if (s == 'out_of_stock' || s == 'outofstock') {
          return prodStatus == 'out_of_stock';
        }
        return prodStatus == s;
      }).toList();
    }

    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all') {
      list = list
          .where((p) =>
              (p['category'] ?? '').toString().toLowerCase() ==
              category.toLowerCase())
          .toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((p) {
        final name = (p['name'] ?? '').toString().toLowerCase();
        final craft = (p['craftType'] ?? '').toString().toLowerCase();
        final material = (p['material'] ?? '').toString().toLowerCase();
        final desc = (p['description'] ?? '').toString().toLowerCase();
        final tags = (p['keywords'] as List<dynamic>?)
                ?.map((e) => e.toString().toLowerCase())
                .toList() ??
            [];
        return name.contains(q) ||
            craft.contains(q) ||
            material.contains(q) ||
            desc.contains(q) ||
            tags.any((t) => t.contains(q));
      }).toList();
    }

    return list;
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    await ensureInitialized();
    try {
      return _products.firstWhere((p) => p['id'] == id || p['_id'] == id);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    await ensureInitialized();
    final newId = 'prod_${DateTime.now().millisecondsSinceEpoch}';

    final raw = (data['rawMaterialCost'] as num?)?.toDouble() ?? 800;
    final prod = (data['productionCost'] as num?)?.toDouble() ?? 500;
    final other = (data['otherCost'] as num?)?.toDouble() ?? 200;
    final total = raw + prod + other;

    final recommended = (data['recommendedPrice'] as num?)?.toDouble() ??
        ((data['price'] as num?)?.toDouble() ?? (total * 1.6).roundToDouble());

    final rawImages = (data['images'] as List<dynamic>?)
            ?.map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    final imagesList = rawImages.isNotEmpty
        ? rawImages
        : [
            'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800'
          ];

    final product = {
      'id': newId,
      '_id': newId,
      'artisanId': _user['id'] ?? 'artisan_demo_001',
      'name': data['name'] ?? 'Handmade Artisan Creation',
      'description': data['description'] ?? '',
      'descriptionHindi': data['descriptionHindi'] ?? data['description'] ?? '',
      'descriptionEnglish':
          data['descriptionEnglish'] ?? data['description'] ?? '',
      'images': imagesList,
      'category': data['category'] ?? 'Textile',
      'material': data['material'] ?? 'Natural Fibers',
      'craftType': data['craftType'] ?? 'Handmade Craft',
      'color': data['color'] ?? 'Multicolor',
      'size': data['size'] ?? 'Standard',
      'quantity': (data['quantity'] as num?)?.toInt() ?? 5,
      'rawMaterialCost': raw,
      'productionCost': prod,
      'otherCost': other,
      'totalCost': total,
      'recommendedPrice': recommended,
      'minimumPrice': (data['minimumPrice'] as num?)?.toDouble() ??
          (total * 1.3).roundToDouble(),
      'competitivePrice': (data['competitivePrice'] as num?)?.toDouble() ??
          (total * 1.5).roundToDouble(),
      'premiumPrice': (data['premiumPrice'] as num?)?.toDouble() ??
          (total * 1.9).roundToDouble(),
      'keywords': (data['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Handmade', 'Artisan', 'GI Craft'],
      'craftStory': data['craftStory'] ??
          'Handcrafted with traditional knowledge passed down through generations.',
      'status': data['status'] ?? 'published',
      'marketplaceStatus': data['marketplaceStatus'] ?? {'ONDC': 'Pending'},
      'createdAt': DateTime.now().toIso8601String(),
    };

    _products.insert(0, product);
    await _saveProducts();
    return product;
  }

  Future<Map<String, dynamic>> updateProduct(
      String id, Map<String, dynamic> data) async {
    await ensureInitialized();
    final index = _products.indexWhere((p) => p['id'] == id || p['_id'] == id);
    if (index != -1) {
      final current = _products[index];
      final updated = Map<String, dynamic>.from(current)..addAll(data);
      _products[index] = updated;
      await _saveProducts();
      return updated;
    }
    return data;
  }

  Future<bool> deleteProduct(String id) async {
    await ensureInitialized();
    final before = _products.length;
    _products.removeWhere((p) => p['id'] == id || p['_id'] == id);
    if (_products.length != before) {
      await _saveProducts();
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> getDashboardSummary() async {
    await ensureInitialized();

    final total = _products.length;
    final published = _products.where((p) => p['status'] == 'published').length;
    final drafts = _products.where((p) => p['status'] == 'draft').length;
    final outOfStock =
        _products.where((p) => p['status'] == 'out_of_stock').length;

    final totalOrders = _orders.length;
    double totalSales = 0;
    for (final ord in _orders) {
      totalSales += (ord['totalAmount'] as num?)?.toDouble() ?? 0;
    }

    final estimatedEarnings =
        totalSales * 0.72; // ~72% profit margin after direct costs

    final recentProducts = _products.take(4).toList();

    return {
      'stats': {
        'totalProducts': total,
        'publishedProducts': published,
        'draftProducts': drafts,
        'outOfStockProducts': outOfStock,
        'totalOrders': totalOrders,
        'totalSales': totalSales,
        'estimatedEarnings': estimatedEarnings,
      },
      'recentProducts': recentProducts,
    };
  }

  // --------------------------------------------------------------------------
  // ORDERS
  // --------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getOrders({String? status}) async {
    await ensureInitialized();
    var list = List<Map<String, dynamic>>.from(_orders);

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      list = list
          .where((o) =>
              (o['status'] ?? '').toString().toLowerCase() ==
              status.toLowerCase())
          .toList();
    }

    return list;
  }

  Future<Map<String, dynamic>?> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? note,
  }) async {
    await ensureInitialized();
    final index =
        _orders.indexWhere((o) => o['id'] == orderId || o['_id'] == orderId);
    if (index != -1) {
      final order = Map<String, dynamic>.from(_orders[index]);
      order['status'] = newStatus;

      final timeline = List<Map<String, dynamic>>.from(
        (order['timeline'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map)) ??
            [],
      );

      String message = note ?? 'Order updated to $newStatus';
      if (newStatus == 'confirmed') {
        message = 'Artisan accepted order and reserved craft stock';
      } else if (newStatus == 'processing') {
        message =
            'Craft inspection and eco-friendly protective packaging underway';
      } else if (newStatus == 'shipped') {
        message =
            'Dispatched via India Post Speed Post (AWB: IN${100000 + (DateTime.now().millisecondsSinceEpoch % 899999)}IN)';
      } else if (newStatus == 'delivered') {
        message = 'Successfully delivered to buyer doorstep';
      }

      timeline.add({
        'status': newStatus,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });

      order['timeline'] = timeline;
      _orders[index] = order;
      await _saveOrders();
      return order;
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // MARKETPLACE
  // --------------------------------------------------------------------------

  Future<Map<String, dynamic>> getMarketplaceData() async {
    await ensureInitialized();
    final total = _listings.length;
    final ondcCount = _listings.where((l) => l['marketplace'] == 'ONDC').length;
    final gemCount = _listings.where((l) => l['marketplace'] == 'GeM').length;

    return {
      'listings': _listings,
      'stats': {
        'totalListings': total,
        'activeListings': total,
        'ondcCount': ondcCount,
        'gemCount': gemCount,
      },
    };
  }

  Future<List<Map<String, dynamic>>> publishToMarketplace(
    String productId, {
    List<String>? marketplaces,
  }) async {
    await ensureInitialized();
    final targets = marketplaces ?? ['ONDC', 'GeM'];
    final created = <Map<String, dynamic>>[];

    for (final mkt in targets) {
      final code = mkt == 'ONDC' ? 'ONDC-IN' : 'GEM-CRAFT';
      final listingId =
          '$code-${100000 + (DateTime.now().millisecondsSinceEpoch % 899999)}';
      final listing = {
        'id': 'mkt_${DateTime.now().millisecondsSinceEpoch}_$mkt',
        '_id': 'mkt_${DateTime.now().millisecondsSinceEpoch}_$mkt',
        'productId': productId,
        'marketplace': mkt,
        'listingId': listingId,
        'status': 'Published',
        'marketplaceCategory': 'Indian Heritage Handicrafts & Handloom',
        'publishedAt': DateTime.now().toIso8601String(),
      };
      _listings.insert(0, listing);
      created.add(listing);
    }

    // Update product marketplace status
    final prod = await getProductById(productId);
    if (prod != null) {
      final currentMkt =
          Map<String, dynamic>.from(prod['marketplaceStatus'] ?? {});
      for (final mkt in targets) {
        currentMkt[mkt] = 'Published';
      }
      await updateProduct(
          productId, {'marketplaceStatus': currentMkt, 'status': 'published'});
    }

    await _saveListings();
    return created;
  }

  // --------------------------------------------------------------------------
  // AUTH & USER
  // --------------------------------------------------------------------------

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    await ensureInitialized();
    return {
      'token':
          'shilpsetu_dummy_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': _user,
    };
  }

  Future<Map<String, dynamic>> demoLogin() async {
    await ensureInitialized();
    return {
      'token': 'shilpsetu_demo_jwt_token_master_artisan',
      'user': _user,
    };
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? preferredLanguage,
    String? location,
    String? craftSpecialty,
  }) async {
    await ensureInitialized();
    _user = {
      'id': 'artisan_${DateTime.now().millisecondsSinceEpoch}',
      '_id': 'artisan_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'phone': phone,
      'email': email ?? '${phone.replaceAll(' ', '')}@shilpsetu.in',
      'preferredLanguage': preferredLanguage ?? 'hi',
      'profileImage':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=400',
      'location': location ?? 'Varanasi, India',
      'craftSpecialty': craftSpecialty ?? 'Traditional Handicrafts',
      'role': 'artisan',
    };
    await _saveUser();

    return {
      'token': 'shilpsetu_reg_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': _user,
    };
  }

  Future<Map<String, dynamic>> getProfile() async {
    await ensureInitialized();
    return _user;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? preferredLanguage,
    String? location,
    String? craftSpecialty,
    String? profileImage,
  }) async {
    await ensureInitialized();
    if (name != null) _user['name'] = name;
    if (preferredLanguage != null) {
      _user['preferredLanguage'] = preferredLanguage;
    }
    if (location != null) _user['location'] = location;
    if (craftSpecialty != null) _user['craftSpecialty'] = craftSpecialty;
    if (profileImage != null) _user['profileImage'] = profileImage;
    await _saveUser();
    return _user;
  }

  // --------------------------------------------------------------------------
  // AI SIMULATIONS (OFFLINE / DUMMY ENGINE)
  // --------------------------------------------------------------------------

  Map<String, dynamic> enhanceImageSimulated({
    required String imagePath,
    bool removeBackground = true,
    bool enhanceLighting = true,
    bool enhanceColors = true,
    bool eCommerceCrop = true,
  }) {
    // If it's an online image or sample image, deliver an enhanced studio version
    final enhancedUrl = imagePath.startsWith('http')
        ? imagePath
        : 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800';

    final appliedCorrections = <String>[];
    if (removeBackground) {
      appliedCorrections
          .add('Background standardized to pure white studio backdrop');
    }
    if (enhanceLighting) {
      appliedCorrections
          .add('Balanced multi-point natural lighting & reduced shadow noise');
    }
    if (enhanceColors) {
      appliedCorrections
          .add('Handicraft mineral dye colors calibrated for high vibrancy');
    }
    if (eCommerceCrop) {
      appliedCorrections
          .add('Centered 1:1 e-commerce ratio with 15% margin padding');
    }

    return {
      'enhancedImage': enhancedUrl,
      'qualityScore': 95,
      'qualityDiagnosis':
          'Studio-grade lighting & texture sharpness optimized for e-commerce conversion',
      'correctionsApplied': appliedCorrections,
    };
  }

  Map<String, dynamic> generateCatalogFromVoice({
    required String inputText,
    String inputLanguage = 'hi',
  }) {
    final text = inputText.toLowerCase();

    String name = 'Handcrafted Artisan Creation';
    String category = 'Textile';
    String material = 'Pure Organic Cotton & Natural Dyes';
    String craftType = 'Traditional Indian Handloom';
    String color = 'Indigo & Ochre Earthy Tones';
    String size = 'Standard / Medium';
    String descHindi =
        'पारंपरिक कारीगरी से निर्मित हस्तशिल्प उत्पाद, जो भारतीय धरोहर और कुशलता का प्रतीक है।';
    String descEnglish =
        'Masterfully handcrafted piece woven with authentic techniques and natural materials for timeless elegance.';
    String craftStory =
        'Each piece represents hours of dedicated craftsmanship by skilled generational artisans.';
    List<String> keywords = ['Handmade', 'Artisan', 'Heritage', 'Natural'];
    double confidence = 94.0;

    if (text.contains('साड़ी') ||
        text.contains('saree') ||
        text.contains('silk') ||
        text.contains('रेशम') ||
        text.contains('शাড়ি')) {
      name = 'Varanasi Handwoven Katan Silk Banarasi Saree';
      category = 'Textile';
      material = '100% Pure Mulberry Silk & Gold Zari';
      craftType = 'Banarasi Handloom Brocade';
      color = 'Royal Crimson & Golden Zari';
      size = '6.5 Meters (With Blouse Piece)';
      descHindi =
          'शुद्ध काटन सिल्क की हाथ से बुनी बनारसी साड़ी, पारंपरिक ज़री और बारीक नक्काशी युक्त।';
      descEnglish =
          'Pure handwoven Katan silk saree with fine gold Zari floral jaal and intricate pallu.';
      craftStory =
          'Hand-woven on heritage pit looms in Varanasi over 14 days by master weavers.';
      keywords = [
        'Banarasi Saree',
        'Pure Silk',
        'Zari',
        'Varanasi',
        'Bridal',
        'Handloom'
      ];
      confidence = 96.0;
    } else if (text.contains('मिट्टी') ||
        text.contains('pottery') ||
        text.contains('फूलदान') ||
        text.contains('vase') ||
        text.contains('clay')) {
      name = 'Jaipur Hand-Painted Blue Pottery Decorative Vase';
      category = 'Pottery';
      material = 'Quartz Powder, Fuller\'s Earth & Natural Glaze';
      craftType = 'Jaipur Blue Pottery';
      color = 'Cobalt Blue & Floral White';
      size = '10 inches Height';
      descHindi =
          'क्वार्ट्ज और खनिज रंगों से तैयार की गई पारंपरिक जयपुर ब्लू पॉटरी की कलाकृति।';
      descEnglish =
          'Authentic Jaipur blue pottery decorative vase hand-painted with Persian floral art.';
      craftStory =
          'Crafted using unique clay-free pottery techniques and kiln-fired by heritage potters.';
      keywords = [
        'Blue Pottery',
        'Jaipur',
        'Handicraft',
        'Ceramic Vase',
        'Home Decor'
      ];
      confidence = 95.0;
    } else if (text.contains('पीतल') ||
        text.contains('brass') ||
        text.contains('दीया') ||
        text.contains('diya') ||
        text.contains('metal')) {
      name = 'Bastar Bell Metal Handcrafted Peacock Diya';
      category = 'Metalware';
      material = 'Pure Brass & Bell Metal';
      craftType = 'Dokra Lost-Wax Metal Casting';
      color = 'Antique Golden Brass';
      size = '8 x 5 inches';
      descHindi =
          'ढोकरा लुप्त-मोम ढलाई पद्धति से निर्मित पारंपरिक पीतल का कलात्मक दीया।';
      descEnglish =
          'Traditional bell metal peacock diya crafted with 4000-year-old tribal lost-wax metallurgy.';
      craftStory =
          'Individually molded in natural beeswax before casting, making every diya a unique original.';
      keywords = [
        'Dokra Diya',
        'Bastar Brass',
        'Lost Wax',
        'Tribal Art',
        'Pooja Decor'
      ];
      confidence = 93.0;
    } else if (text.contains('लकड़ी') ||
        text.contains('wood') ||
        text.contains('खिलौने') ||
        text.contains('toy') ||
        text.contains('चन्नापटना')) {
      name = 'Channapatna Non-Toxic Wooden Stacking Toy';
      category = 'Woodwork';
      material = 'Aale Mara (Ivory Wood) & Herbal Vegetable Lacquer';
      craftType = 'Channapatna Lacquerware';
      color = 'Vibrant Multi-Color Organic Dyes';
      size = '7 Graduated Rings';
      descHindi =
          'प्राकृतिक वनस्पति रंगों से रंगे पर्यावरण अनुकूल और सुरक्षित लकड़ी के खिलौने।';
      descEnglish =
          'Eco-friendly wooden toy handcrafted using organic vegetable lacquers safe for kids.';
      craftStory =
          'Hand-turned on traditional wood lathes and polished with talc leaf for high glass finish.';
      keywords = [
        'Channapatna',
        'Wooden Toy',
        'Eco Friendly',
        'Non Toxic',
        'Kids Safe'
      ];
      confidence = 97.0;
    }

    return {
      'catalog': {
        'name': name,
        'description': descEnglish,
        'descriptionHindi': descHindi,
        'descriptionEnglish': descEnglish,
        'category': category,
        'material': material,
        'craftType': craftType,
        'color': color,
        'size': size,
        'keywords': keywords,
        'craftStory': craftStory,
        'confidence': confidence,
      },
    };
  }

  Map<String, dynamic> generatePricingSimulated({
    required double rawMaterialCost,
    required double productionCost,
    required double otherCost,
    String category = 'Textile',
    String craftType = '',
    String material = '',
  }) {
    final total = rawMaterialCost + productionCost + otherCost;

    // Craft industry benchmark multipliers
    double marginMultiplier = 1.6;
    if (category == 'Textile') marginMultiplier = 1.65;
    if (category == 'Painting') marginMultiplier = 1.8;
    if (category == 'Pottery') marginMultiplier = 1.55;
    if (category == 'Metalware') marginMultiplier = 1.6;

    final recommended = (total * marginMultiplier).roundToDouble();
    final min = (total * 1.3).roundToDouble();
    final competitive = (total * 1.5).roundToDouble();
    final premium = (total * 1.95).roundToDouble();

    final profit = recommended - total;
    final profitMargin = ((profit / recommended) * 1000).round() / 10.0;

    return {
      'pricing': {
        'rawMaterialCost': rawMaterialCost,
        'productionCost': productionCost,
        'otherCost': otherCost,
        'totalCost': total,
        'minimumPrice': min,
        'competitivePrice': competitive,
        'recommendedPrice': recommended,
        'premiumPrice': premium,
        'estimatedProfit': profit,
        'profitMargin': profitMargin,
        'marketTrend':
            'High consumer demand on ONDC and premium domestic craft platforms (+18% YoY)',
        'explanation':
            'Calculated based on 40% artisan labor margin, fair material compensation, and verified ONDC price bands for $category.',
        'disclaimer':
            'AI pricing is formulated using handicraft commerce indices. Final selling price is at artisan discretion.',
      },
    };
  }

  Future<List<Map<String, dynamic>>> visualSearchSimulated({
    String? imagePath,
    String category = 'Textile',
  }) async {
    await ensureInitialized();
    final matchedProducts =
        _products.where((p) => p['category'] == category).toList();
    final list = matchedProducts.isNotEmpty
        ? matchedProducts
        : _products.take(3).toList();

    final results = <Map<String, dynamic>>[];
    int score = 94;

    for (final prod in list) {
      results.add({
        'product': prod,
        'similarityScore': score,
        'matchReason':
            'High visual pattern match with ${prod['craftType']} (${prod['material']})',
      });
      score -= 5;
    }

    return results;
  }
}
