import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../shared/models/product_model.dart';

class ProductRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<ProductModel>> getProducts({
    String? status,
    String? category,
    String? search,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.products,
        queryParameters: {
          if (status != null && status != 'all') 'status': status,
          if (category != null && category != 'All') 'category': category,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final list = response.data['data']['products'] as List<dynamic>;
      return list.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.products}/$id');
      return ProductModel.fromJson(response.data['data']['product']);
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }

  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.products,
        data: productData,
      );
      return ProductModel.fromJson(response.data['data']['product']);
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }

  Future<ProductModel> updateProduct(
      String id, Map<String, dynamic> productData) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.products}/$id',
        data: productData,
      );
      return ProductModel.fromJson(response.data['data']['product']);
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _apiClient.dio.delete('${ApiConstants.products}/$id');
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }
}
