import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'mock_database.dart';

class MockInterceptor extends Interceptor {
  final MockDatabase _db = MockDatabase();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;
    final method = options.method.toUpperCase();

    if (kDebugMode) {
      print('[MockBackend Interceptor] Handling $method $path');
    }

    // Small async delay to provide realistic snappy UX with smooth loading indicators
    await Future.delayed(const Duration(milliseconds: 180));

    try {
      dynamic data = options.data;
      if (data is FormData) {
        // Convert FormData fields to map for easy parsing
        final map = <String, dynamic>{};
        for (final field in data.fields) {
          map[field.key] = field.value;
        }
        data = map;
      }

      // ----------------------------------------------------------------------
      // AUTH
      // ----------------------------------------------------------------------
      if (path.endsWith('/auth/login')) {
        final phone = data?['phone'] ?? '9876543210';
        final password = data?['password'] ?? '';
        final res = await _db.login(phone: phone, password: password);
        return handler.resolve(_successResponse(options, res));
      }

      if (path.endsWith('/auth/demo-artisan')) {
        final res = await _db.demoLogin();
        return handler.resolve(_successResponse(options, res));
      }

      if (path.endsWith('/auth/register')) {
        final name = data?['name'] ?? 'Artisan';
        final phone = data?['phone'] ?? '9876543210';
        final password = data?['password'] ?? '';
        final email = data?['email'];
        final preferredLanguage = data?['preferredLanguage'];
        final location = data?['location'];
        final craftSpecialty = data?['craftSpecialty'];

        final res = await _db.register(
          name: name,
          phone: phone,
          password: password,
          email: email,
          preferredLanguage: preferredLanguage,
          location: location,
          craftSpecialty: craftSpecialty,
        );
        return handler.resolve(_successResponse(options, res));
      }

      if (path.endsWith('/auth/me')) {
        final user = await _db.getProfile();
        return handler.resolve(_successResponse(options, {'user': user}));
      }

      if (path.endsWith('/auth/profile')) {
        final user = await _db.updateProfile(
          name: data?['name'],
          preferredLanguage: data?['preferredLanguage'],
          location: data?['location'],
          craftSpecialty: data?['craftSpecialty'],
          profileImage: data?['profileImage'],
        );
        return handler.resolve(_successResponse(options, {'user': user}));
      }

      // ----------------------------------------------------------------------
      // PRODUCTS
      // ----------------------------------------------------------------------
      if (path.contains('/products/stats/summary') ||
          path.contains('/products/stats')) {
        final summary = await _db.getDashboardSummary();
        return handler.resolve(_successResponse(options, summary));
      }

      // Single Product by ID (GET, PUT, DELETE)
      final productMatch = RegExp(r'/products/([^/?]+)').firstMatch(path);
      if (productMatch != null &&
          !path.contains('/stats') &&
          productMatch.group(1) != 'stats') {
        final productId = productMatch.group(1)!;

        if (method == 'GET') {
          final prod = await _db.getProductById(productId);
          if (prod != null) {
            return handler
                .resolve(_successResponse(options, {'product': prod}));
          }
          return handler.reject(DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 404,
              data: {'success': false, 'message': 'Product not found'},
            ),
          ));
        }

        if (method == 'PUT') {
          final updated = await _db.updateProduct(
              productId, Map<String, dynamic>.from(data ?? {}));
          return handler
              .resolve(_successResponse(options, {'product': updated}));
        }

        if (method == 'DELETE') {
          await _db.deleteProduct(productId);
          return handler.resolve(_successResponse(
              options, {'message': 'Product deleted successfully'}));
        }
      }

      // Products List & Create
      if (path.endsWith('/products') || path.contains('/products?')) {
        if (method == 'GET') {
          final status = options.queryParameters['status'];
          final category = options.queryParameters['category'];
          final search = options.queryParameters['search'];

          final list = await _db.getProducts(
            status: status,
            category: category,
            search: search,
          );
          return handler.resolve(_successResponse(
              options, {'products': list, 'count': list.length}));
        }

        if (method == 'POST') {
          final created =
              await _db.createProduct(Map<String, dynamic>.from(data ?? {}));
          return handler
              .resolve(_successResponse(options, {'product': created}));
        }
      }

      // ----------------------------------------------------------------------
      // AI SERVICES
      // ----------------------------------------------------------------------
      if (path.endsWith('/ai/image-enhance')) {
        final imagePath = data?['imagePath'] ??
            'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800';
        final removeBg = data?['removeBackground']?.toString() != 'false';
        final enhanceLight = data?['enhanceLighting']?.toString() != 'false';
        final enhanceCol = data?['enhanceColors']?.toString() != 'false';
        final crop = data?['eCommerceCrop']?.toString() != 'false';

        final res = _db.enhanceImageSimulated(
          imagePath: imagePath,
          removeBackground: removeBg,
          enhanceLighting: enhanceLight,
          enhanceColors: enhanceCol,
          eCommerceCrop: crop,
        );
        return handler.resolve(_successResponse(options, res));
      }

      if (path.endsWith('/ai/catalog') || path.endsWith('/ai/voice')) {
        final text = data?['inputText'] ?? data?['text'] ?? '';
        final lang = data?['inputLanguage'] ?? data?['language'] ?? 'hi';

        final res =
            _db.generateCatalogFromVoice(inputText: text, inputLanguage: lang);
        return handler.resolve(_successResponse(options, res));
      }

      if (path.endsWith('/ai/pricing')) {
        final raw = (data?['rawMaterialCost'] as num?)?.toDouble() ?? 800;
        final prod = (data?['productionCost'] as num?)?.toDouble() ?? 500;
        final other = (data?['otherCost'] as num?)?.toDouble() ?? 200;
        final cat = data?['category'] ?? 'Textile';
        final craft = data?['craftType'] ?? '';
        final mat = data?['material'] ?? '';

        final res = _db.generatePricingSimulated(
          rawMaterialCost: raw,
          productionCost: prod,
          otherCost: other,
          category: cat,
          craftType: craft,
          material: mat,
        );
        return handler.resolve(_successResponse(options, res));
      }

      // ----------------------------------------------------------------------
      // ORDERS
      // ----------------------------------------------------------------------
      final orderStatusMatch =
          RegExp(r'/orders/([^/]+)/status').firstMatch(path);
      if (orderStatusMatch != null && method == 'PATCH') {
        final orderId = orderStatusMatch.group(1)!;
        final status = data?['status'] ?? 'confirmed';
        final note = data?['note'];

        final updated =
            await _db.updateOrderStatus(orderId, status, note: note);
        return handler.resolve(_successResponse(options, {'order': updated}));
      }

      if (path.endsWith('/orders') || path.contains('/orders?')) {
        final status = options.queryParameters['status'];
        final list = await _db.getOrders(status: status);
        return handler.resolve(
            _successResponse(options, {'orders': list, 'count': list.length}));
      }

      // ----------------------------------------------------------------------
      // MARKETPLACE
      // ----------------------------------------------------------------------
      if (path.endsWith('/marketplace/listings')) {
        final mkt = await _db.getMarketplaceData();
        return handler.resolve(_successResponse(options, mkt));
      }

      if (path.endsWith('/marketplace/publish')) {
        final productId = data?['productId'] ?? '';
        final marketplaces = (data?['marketplaces'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();

        final created = await _db.publishToMarketplace(productId,
            marketplaces: marketplaces);
        return handler
            .resolve(_successResponse(options, {'listings': created}));
      }

      // ----------------------------------------------------------------------
      // SEARCH
      // ----------------------------------------------------------------------
      if (path.endsWith('/search/visual')) {
        final imagePath = data?['imagePath'];
        final category = data?['category'] ?? 'Textile';

        final results = await _db.visualSearchSimulated(
            imagePath: imagePath, category: category);
        return handler.resolve(_successResponse(options, {'results': results}));
      }

      // Fallback 200 OK for any unmapped route to guarantee graceful offline operation
      return handler.resolve(_successResponse(
          options, {'message': 'Operation successful (Mock Mode)'}));
    } catch (e) {
      if (kDebugMode) {
        print('[MockBackend Interceptor] Error processing $path: $e');
      }
      return handler.resolve(_successResponse(options, {'message': 'Success'}));
    }
  }

  Response<Map<String, dynamic>> _successResponse(
    RequestOptions options,
    dynamic data,
  ) {
    return Response<Map<String, dynamic>>(
      requestOptions: options,
      statusCode: 200,
      data: {
        'success': true,
        'data': data,
      },
    );
  }
}
