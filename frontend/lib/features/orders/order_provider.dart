import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/order_model.dart';
import 'order_repository.dart';

final orderRepositoryProvider =
    Provider<OrderRepository>((ref) => OrderRepository());

class OrderState {
  final List<OrderModel> orders;
  final String selectedFilter;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.selectedFilter = 'all',
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    String? selectedFilter,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;

  OrderNotifier(this._repository) : super(const OrderState()) {
    fetchOrders();
  }

  Future<void> fetchOrders({String? status}) async {
    final activeStatus = status ?? state.selectedFilter;
    state = state.copyWith(
        isLoading: true, selectedFilter: activeStatus, error: null);

    try {
      final list = await _repository.getOrders(
        status: activeStatus == 'all' ? null : activeStatus,
      );
      state = state.copyWith(orders: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus,
      {String? note}) async {
    try {
      await _repository.updateOrderStatus(orderId, newStatus, note: note);
      await fetchOrders();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderNotifier(repository);
});

