import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/product_model.dart';
import 'product_repository.dart';

final productRepositoryProvider =
    Provider<ProductRepository>((ref) => ProductRepository());

class ProductListState {
  final List<ProductModel> products;
  final bool isLoading;
  final String? error;
  final String selectedTab;
  final String searchQuery;

  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.selectedTab = 'all',
    this.searchQuery = '',
  });

  ProductListState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    String? error,
    String? selectedTab,
    String? searchQuery,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRepository _repository;

  ProductListNotifier(this._repository) : super(const ProductListState()) {
    fetchProducts();
  }

  Future<void> fetchProducts({String? tab, String? search}) async {
    final activeTab = tab ?? state.selectedTab;
    final activeSearch = search ?? state.searchQuery;

    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedTab: activeTab,
      searchQuery: activeSearch,
    );

    try {
      final products = await _repository.getProducts(
        status: activeTab == 'all' ? null : activeTab,
        search: activeSearch.isEmpty ? null : activeSearch,
      );
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    try {
      await _repository.createProduct(data);
      await fetchProducts();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateProduct(id, data);
      await fetchProducts();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      state = state.copyWith(
        products: state.products.where((p) => p.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductListNotifier(repository);
});
