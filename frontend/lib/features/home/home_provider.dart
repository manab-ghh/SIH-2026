import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../shared/models/product_model.dart';

class DashboardStats {
  final int totalProducts;
  final int publishedProducts;
  final int draftProducts;
  final int outOfStockProducts;
  final int totalOrders;
  final double totalSales;
  final double estimatedEarnings;

  const DashboardStats({
    this.totalProducts = 0,
    this.publishedProducts = 0,
    this.draftProducts = 0,
    this.outOfStockProducts = 0,
    this.totalOrders = 0,
    this.totalSales = 0,
    this.estimatedEarnings = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      publishedProducts: (json['publishedProducts'] as num?)?.toInt() ?? 0,
      draftProducts: (json['draftProducts'] as num?)?.toInt() ?? 0,
      outOfStockProducts: (json['outOfStockProducts'] as num?)?.toInt() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0,
      estimatedEarnings: (json['estimatedEarnings'] as num?)?.toDouble() ?? 0,
    );
  }
}

class HomeState {
  final DashboardStats stats;
  final List<ProductModel> recentProducts;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.stats = const DashboardStats(),
    this.recentProducts = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    DashboardStats? stats,
    List<ProductModel>? recentProducts,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      stats: stats ?? this.stats,
      recentProducts: recentProducts ?? this.recentProducts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final ApiClient _apiClient = ApiClient();

  HomeNotifier() : super(const HomeState()) {
    fetchDashboardSummary();
  }

  Future<void> fetchDashboardSummary() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.get(ApiConstants.productStats);
      final statsData = response.data['data']['stats'];
      final recentData =
          response.data['data']['recentProducts'] as List<dynamic>?;

      final stats = DashboardStats.fromJson(statsData);
      final recent =
          recentData?.map((e) => ProductModel.fromJson(e)).toList() ?? [];

      state = state.copyWith(
        stats: stats,
        recentProducts: recent,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiClient.formatError(e));
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
