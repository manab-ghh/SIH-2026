import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../shared/models/pricing_model.dart';

class PricingState {
  final double rawMaterialCost;
  final double productionCost;
  final double otherCost;
  final String category;
  final String craftType;
  final String material;
  final PricingModel? pricing;
  final bool isCalculating;
  final String? error;

  const PricingState({
    this.rawMaterialCost = 800,
    this.productionCost = 500,
    this.otherCost = 200,
    this.category = 'Textile',
    this.craftType = '',
    this.material = '',
    this.pricing,
    this.isCalculating = false,
    this.error,
  });

  double get totalCost => rawMaterialCost + productionCost + otherCost;

  PricingState copyWith({
    double? rawMaterialCost,
    double? productionCost,
    double? otherCost,
    String? category,
    String? craftType,
    String? material,
    PricingModel? pricing,
    bool? isCalculating,
    String? error,
  }) {
    return PricingState(
      rawMaterialCost: rawMaterialCost ?? this.rawMaterialCost,
      productionCost: productionCost ?? this.productionCost,
      otherCost: otherCost ?? this.otherCost,
      category: category ?? this.category,
      craftType: craftType ?? this.craftType,
      material: material ?? this.material,
      pricing: pricing ?? this.pricing,
      isCalculating: isCalculating ?? this.isCalculating,
      error: error,
    );
  }
}

class PricingNotifier extends StateNotifier<PricingState> {
  final ApiClient _apiClient = ApiClient();

  PricingNotifier({
    double raw = 800,
    double prod = 500,
    double other = 200,
    String category = 'Textile',
  }) : super(PricingState(
          rawMaterialCost: raw,
          productionCost: prod,
          otherCost: other,
          category: category,
        )) {
    calculatePrice();
  }

  void updateCosts({
    double? rawMaterialCost,
    double? productionCost,
    double? otherCost,
    String? category,
  }) {
    state = state.copyWith(
      rawMaterialCost: rawMaterialCost,
      productionCost: productionCost,
      otherCost: otherCost,
      category: category,
    );
    calculatePrice();
  }

  Future<void> calculatePrice() async {
    state = state.copyWith(isCalculating: true, error: null);

    try {
      final response = await _apiClient.dio.post(
        ApiConstants.pricingGenerate,
        data: {
          'rawMaterialCost': state.rawMaterialCost,
          'productionCost': state.productionCost,
          'otherCost': state.otherCost,
          'category': state.category,
          'craftType': state.craftType,
          'material': state.material,
        },
      );

      final pricingData = response.data['data']['pricing'];
      final pricing = PricingModel.fromJson(pricingData);

      state = state.copyWith(
        pricing: pricing,
        isCalculating: false,
      );
    } catch (e) {
      // Local fallback calculation if offline
      final total = state.totalCost;
      final recommended = (total * 1.6).roundToDouble();
      final min = (total * 1.3).roundToDouble();
      final competitive = (total * 1.5).roundToDouble();
      final premium = (total * 1.9).roundToDouble();
      final profit = recommended - total;
      final margin = _roundToOneDecimal((profit / recommended) * 100);

      state = state.copyWith(
        pricing: PricingModel(
          rawMaterialCost: state.rawMaterialCost,
          productionCost: state.productionCost,
          otherCost: state.otherCost,
          totalCost: total,
          minimumPrice: min,
          competitivePrice: competitive,
          recommendedPrice: recommended,
          premiumPrice: premium,
          estimatedProfit: profit,
          profitMargin: margin,
          marketTrend: 'Positive demand for handmade crafts',
          explanation: 'Estimated using standard craft margin benchmarks.',
        ),
        isCalculating: false,
      );
    }
  }

  double _roundToOneDecimal(double val) => (val * 10).round() / 10;
}

final pricingProvider = StateNotifierProvider.autoDispose
    .family<PricingNotifier, PricingState, Map<String, dynamic>>(
  (ref, args) => PricingNotifier(
    raw: (args['raw'] as num?)?.toDouble() ?? 800,
    prod: (args['prod'] as num?)?.toDouble() ?? 500,
    other: (args['other'] as num?)?.toDouble() ?? 200,
    category: args['category'] ?? 'Textile',
  ),
);
