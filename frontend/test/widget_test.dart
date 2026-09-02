import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/localization/app_localizations.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/core/widgets/empty_state.dart';
import 'package:frontend/core/widgets/status_badge.dart';
import 'package:frontend/shared/models/catalog_model.dart';
import 'package:frontend/shared/models/marketplace_model.dart';
import 'package:frontend/shared/models/order_model.dart';
import 'package:frontend/shared/models/pricing_model.dart';
import 'package:frontend/shared/models/product_model.dart';
import 'package:frontend/shared/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/login_screen.dart';
import 'package:frontend/features/home/widgets/quick_action_card.dart';
import 'package:frontend/core/mock/mock_database.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('ShilpSetu AI Model Serialization Tests', () {
    test('UserModel fromJson / toJson', () {
      final json = {
        'id': 'user-123',
        'name': 'Ramu Weaver',
        'phone': '9876543210',
        'craftSpecialty': 'Chanderi Saree Weaving',
        'location': 'Varanasi, UP',
        'preferredLanguage': 'hi',
        'profileImage': 'https://example.com/profile.jpg',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'user-123');
      expect(user.name, 'Ramu Weaver');
      expect(user.craftSpecialty, 'Chanderi Saree Weaving');
      expect(user.preferredLanguage, 'hi');
      expect(user.toJson()['phone'], '9876543210');
    });

    test('ProductModel fromJson / toJson', () {
      final json = {
        '_id': 'prod-001',
        'name': 'Handloom Cotton Saree',
        'description': 'Pure organic handwoven cotton',
        'category': 'Textile',
        'material': 'Organic Cotton',
        'craftType': 'Handloom Weaving',
        'color': 'Indigo',
        'size': '6.3 Meters',
        'quantity': 10,
        'rawMaterialCost': 800,
        'productionCost': 500,
        'otherCost': 200,
        'totalCost': 1500,
        'recommendedPrice': 2499,
        'status': 'published',
        'images': ['https://example.com/saree.jpg'],
        'craftStory': 'Handcrafted with tradition.',
      };

      final prod = ProductModel.fromJson(json);
      expect(prod.id, 'prod-001');
      expect(prod.name, 'Handloom Cotton Saree');
      expect(prod.category, 'Textile');
      expect(prod.recommendedPrice, 2499);
      expect(prod.totalCost, 1500);
      expect(prod.status, 'published');
    });

    test('OrderModel fromJson', () {
      final json = {
        '_id': 'ord-001',
        'orderNumber': 'SHL-99887',
        'productId': 'prod-001',
        'productName': 'Terracotta Vase',
        'productImage': 'https://example.com/vase.jpg',
        'buyerName': 'Amit Verma',
        'buyerPhone': '9876543211',
        'quantity': 2,
        'price': 1200,
        'totalAmount': 2400,
        'status': 'processing',
        'timeline': [
          {
            'status': 'pending',
            'message': 'Order placed',
            'timestamp': '2026-08-28T12:00:00Z',
          }
        ],
        'createdAt': '2026-08-28T12:00:00Z',
      };

      final order = OrderModel.fromJson(json);
      expect(order.orderNumber, 'SHL-99887');
      expect(order.buyerName, 'Amit Verma');
      expect(order.totalAmount, 2400);
      expect(order.timeline.length, 1);
    });

    test('PricingModel fromJson', () {
      final json = {
        'rawMaterialCost': 600,
        'productionCost': 400,
        'otherCost': 100,
        'totalCost': 1100,
        'minimumPrice': 1430,
        'competitivePrice': 1650,
        'recommendedPrice': 1760,
        'premiumPrice': 2090,
        'estimatedProfit': 660,
        'profitMargin': 37.5,
        'marketTrend': 'High festive demand',
        'explanation': 'Artisan craft margin applied',
      };

      final pricing = PricingModel.fromJson(json);
      expect(pricing.totalCost, 1100);
      expect(pricing.recommendedPrice, 1760);
      expect(pricing.profitMargin, 37.5);
    });

    test('CatalogModel fromJson', () {
      final json = {
        'name': 'Dhokra Brass Figurine',
        'description': 'Ancient lost-wax bell metal craft',
        'descriptionHindi': 'ढोकरा पीतल शिल्प',
        'category': 'Metalware',
        'material': 'Bell Metal / Brass',
        'craftType': 'Dhokra Lost-Wax',
        'color': 'Antique Gold',
        'size': '8x4 inches',
        'keywords': ['dhokra', 'brass', 'tribal'],
        'confidence': 95.0,
      };

      final catalog = CatalogModel.fromJson(json);
      expect(catalog.name, 'Dhokra Brass Figurine');
      expect(catalog.craftType, 'Dhokra Lost-Wax');
      expect(catalog.keywords.length, 3);
    });

    test('MarketplaceListingModel fromJson', () {
      final json = {
        '_id': 'mkt-001',
        'productId': 'prod-001',
        'marketplace': 'ONDC',
        'listingId': 'ONDC-DEMO-9911',
        'status': 'Published',
        'marketplaceCategory': 'Handlooms',
        'publishedAt': '2026-08-28T12:00:00Z',
      };

      final listing = MarketplaceListingModel.fromJson(json);
      expect(listing.marketplace, 'ONDC');
      expect(listing.listingId, 'ONDC-DEMO-9911');
      expect(listing.status, 'Published');
    });
  });

  group('Localization Verification Tests', () {
    test('Hindi and English dictionaries load correctly', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locHi = AppLocalizations(const Locale('hi'));
      final locBn = AppLocalizations(const Locale('bn'));

      expect(locEn.tagline, 'Your AI Business Manager');
      expect(locHi.taglineHindi, 'आपके हुनर का डिजिटल साथी');
      expect(locBn.namasteArtisan, 'নমস্কার');
    });
  });

  group('Reusable Core Widget Tests', () {
    testWidgets('CustomButton renders and handles taps', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Save Craft',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Save Craft'), findsOneWidget);
      await tester.tap(find.text('Save Craft'));
      expect(tapped, isTrue);
    });

    testWidgets('StatusBadge renders correct label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'published'),
          ),
        ),
      );

      expect(find.text('Published'), findsOneWidget);
    });

    testWidgets('EmptyState displays title and description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No Products',
              description: 'Create your first product.',
            ),
          ),
        ),
      );

      expect(find.text('No Products'), findsOneWidget);
      expect(find.text('Create your first product.'), findsOneWidget);
    });

    testWidgets(
        'QuickActionCard renders cleanly on tight mobile viewport without overflow',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 160,
                height: 130,
                child: QuickActionCard(
                  title: 'Product Studio',
                  subtitle: 'AI Photo Lighting & BG',
                  icon: Icons.camera_enhance_rounded,
                  gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Product Studio'), findsOneWidget);
      expect(find.text('AI Photo Lighting & BG'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'LoginScreen renders create account footer cleanly without overflow on narrow 360px viewport',
        (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('Welcome to ShilpSetu AI'), findsOneWidget);
      expect(find.text('Create Account / नया खाता'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Offline Standalone MockBackend & ApiClient Tests', () {
    test('MockDatabase initializes with rich seed data', () async {
      final db = MockDatabase();
      await db.ensureInitialized();

      final products = await db.getProducts();
      expect(products.length, greaterThanOrEqualTo(10));

      final orders = await db.getOrders();
      expect(orders.length, greaterThanOrEqualTo(5));

      final stats = await db.getDashboardSummary();
      expect(stats['stats']['totalProducts'], greaterThanOrEqualTo(10));
      expect(stats['stats']['totalOrders'], greaterThanOrEqualTo(5));
    });

    test('ApiClient offline demo auth & products workflow', () async {
      final apiClient = ApiClient();

      // Demo login
      final authRes = await apiClient.dio.post('/auth/demo-artisan');
      expect(authRes.statusCode, 200);
      expect(authRes.data['success'], isTrue);
      expect(authRes.data['data']['user']['name'], 'Ramkishan Verma');

      // Fetch products
      final prodRes = await apiClient.dio.get('/products');
      expect(prodRes.statusCode, 200);
      expect(prodRes.data['data']['products'], isNotEmpty);

      // Create product
      final newProdRes = await apiClient.dio.post('/products', data: {
        'name': 'Test Madhubani Silk Painting',
        'category': 'Painting',
        'rawMaterialCost': 1000,
        'productionCost': 800,
        'otherCost': 200,
        'recommendedPrice': 3499,
      });
      expect(newProdRes.statusCode, 200);
      expect(newProdRes.data['data']['product']['name'],
          'Test Madhubani Silk Painting');

      // AI Pricing generator test
      final pricingRes = await apiClient.dio.post('/ai/pricing', data: {
        'rawMaterialCost': 1000,
        'productionCost': 800,
        'otherCost': 200,
        'category': 'Painting',
      });
      expect(pricingRes.statusCode, 200);
      expect(pricingRes.data['data']['pricing']['recommendedPrice'],
          greaterThan(2000));

      // AI Voice catalog generator test
      final voiceRes = await apiClient.dio.post('/ai/catalog', data: {
        'inputText': 'शुद्ध काटन सिल्क की हाथ से बुनी बनारसी साड़ी',
        'inputLanguage': 'hi',
      });
      expect(voiceRes.statusCode, 200);
      expect(
          voiceRes.data['data']['catalog']['name'], contains('Banarasi Saree'));

      // Order status transition test
      final orderPatchRes =
          await apiClient.dio.patch('/orders/ord_001/status', data: {
        'status': 'confirmed',
      });
      expect(orderPatchRes.statusCode, 200);
      expect(orderPatchRes.data['data']['order']['status'], 'confirmed');
    });
  });
}
