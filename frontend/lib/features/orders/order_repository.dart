import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../shared/models/order_model.dart';

class OrderRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<OrderModel>> getOrders({String? status}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.orders,
        queryParameters: (status == null || status == 'all')
            ? {}
            : {'status': status},
      );
      final list = response.data['data']['orders'] as List<dynamic>;
      return list.map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }

  Future<OrderModel> getOrderById(String id) async {
    try {
      final response =
          await _apiClient.dio.get('${ApiConstants.orders}/$id');
      return OrderModel.fromJson(response.data['data']['order']);
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }

  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.orders,
        data: data,
      );
      return OrderModel.fromJson(response.data['data']['order']);
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }

  Future<OrderModel> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? note,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiConstants.orders}/$orderId/status',
        data: {
          'status': newStatus,
          if (note != null) 'note': note,
        },
      );
      return OrderModel.fromJson(response.data['data']['order']);
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }
}
