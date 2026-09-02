import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../shared/models/product_model.dart';

class VisualSearchResult {
  final ProductModel product;
  final int similarityScore;
  final String matchReason;

  const VisualSearchResult({
    required this.product,
    required this.similarityScore,
    required this.matchReason,
  });

  factory VisualSearchResult.fromJson(Map<String, dynamic> json) {
    return VisualSearchResult(
      product: ProductModel.fromJson(json['product']),
      similarityScore: (json['similarityScore'] as num?)?.toInt() ?? 85,
      matchReason: json['matchReason'] ?? 'High visual and craft similarity',
    );
  }
}

class SearchState {
  final List<VisualSearchResult> results;
  final String? searchImagePath;
  final String selectedCategory;
  final bool isSearching;
  final String? error;

  const SearchState({
    this.results = const [],
    this.searchImagePath,
    this.selectedCategory = 'Textile',
    this.isSearching = false,
    this.error,
  });

  SearchState copyWith({
    List<VisualSearchResult>? results,
    String? searchImagePath,
    String? selectedCategory,
    bool? isSearching,
    String? error,
  }) {
    return SearchState(
      results: results ?? this.results,
      searchImagePath: searchImagePath ?? this.searchImagePath,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isSearching: isSearching ?? this.isSearching,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ApiClient _apiClient = ApiClient();

  SearchNotifier() : super(const SearchState()) {
    performSearch(category: 'Textile');
  }

  Future<void> performSearch({String? imagePath, String? category}) async {
    final cat = category ?? state.selectedCategory;
    state = state.copyWith(
      isSearching: true,
      searchImagePath: imagePath,
      selectedCategory: cat,
      error: null,
    );

    try {
      final response = await _apiClient.dio.post(
        ApiConstants.visualSearch,
        data: {
          'category': cat,
          if (imagePath != null) 'imagePath': imagePath,
        },
      );

      final listData = response.data['data']['results'] as List<dynamic>;
      final list = listData.map((e) => VisualSearchResult.fromJson(e)).toList();

      state = state.copyWith(results: list, isSearching: false);
    } catch (e) {
      state =
          state.copyWith(isSearching: false, error: ApiClient.formatError(e));
    }
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
