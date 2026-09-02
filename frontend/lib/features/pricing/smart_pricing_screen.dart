import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/custom_button.dart';
import 'pricing_provider.dart';

class SmartPricingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialData;

  const SmartPricingScreen({super.key, this.initialData = const {}});

  @override
  ConsumerState<SmartPricingScreen> createState() => _SmartPricingScreenState();
}

class _SmartPricingScreenState extends ConsumerState<SmartPricingScreen> {
  late TextEditingController _rawCostController;
  late TextEditingController _prodCostController;
  late TextEditingController _otherCostController;

  @override
  void initState() {
    super.initState();
    _rawCostController = TextEditingController(
      text: (widget.initialData['raw'] ?? 800).toString(),
    );
    _prodCostController = TextEditingController(
      text: (widget.initialData['prod'] ?? 500).toString(),
    );
    _otherCostController = TextEditingController(
      text: (widget.initialData['other'] ?? 200).toString(),
    );
  }

  @override
  void dispose() {
    _rawCostController.dispose();
    _prodCostController.dispose();
    _otherCostController.dispose();
    super.dispose();
  }

  void _triggerCalculation() {
    final raw = double.tryParse(_rawCostController.text) ?? 0;
    final prod = double.tryParse(_prodCostController.text) ?? 0;
    final other = double.tryParse(_otherCostController.text) ?? 0;

    ref.read(pricingProvider(widget.initialData).notifier).updateCosts(
          rawMaterialCost: raw,
          productionCost: prod,
          otherCost: other,
        );
  }

  @override
  Widget build(BuildContext context) {
    final pricingState = ref.watch(pricingProvider(widget.initialData));
    final pricing = pricingState.pricing;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Smart Pricing Assistant 💰'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Recommended Price Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF047857), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'AI Recommended Selling Price',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${pricing?.recommendedPrice.toInt() ?? 2499}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Profit and Margin Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up_rounded,
                              color: Colors.amberAccent, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Estimated Profit: ₹${pricing?.estimatedProfit.toInt() ?? 999} (${pricing?.profitMargin ?? 39.9}%)',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Simulated Market Notice Badge
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.insights_rounded,
                        color: Color(0xFFB45309), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo Market Insights: AI suggestions are calculated from cost factors & category trends.',
                        style: TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Cost Breakdown Inputs
              const Text(
                'Your Craft Cost Breakdown (लागत)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    _buildCostInput(
                      label: 'Raw Material Cost (कच्चा माल)',
                      controller: _rawCostController,
                      onChanged: (_) => _triggerCalculation(),
                    ),
                    const Divider(height: 16, color: AppColors.surfaceBorder),
                    _buildCostInput(
                      label: 'Production & Artisan Labor (कारीगरी)',
                      controller: _prodCostController,
                      onChanged: (_) => _triggerCalculation(),
                    ),
                    const Divider(height: 16, color: AppColors.surfaceBorder),
                    _buildCostInput(
                      label: 'Packaging & Other Costs (पैकेजिंग)',
                      controller: _otherCostController,
                      onChanged: (_) => _triggerCalculation(),
                    ),
                    const Divider(
                        height: 20,
                        color: AppColors.surfaceBorder,
                        thickness: 1.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Total Production Cost',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${pricingState.totalCost.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 4 Market Price Tiers
              const Text(
                'Price Recommendations by Market Tier',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: _buildTierCard(
                      title: 'Minimum Safe',
                      price: '₹${pricing?.minimumPrice.toInt() ?? 2000}',
                      tag: 'Living Wage',
                      color: const Color(0xFF6B7280),
                      bgColor: const Color(0xFFF3F4F6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTierCard(
                      title: 'Competitive',
                      price: '₹${pricing?.competitivePrice.toInt() ?? 2400}',
                      tag: 'High Volume',
                      color: AppColors.secondary,
                      bgColor: AppColors.secondaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTierCard(
                      title: 'AI Recommended',
                      price: '₹${pricing?.recommendedPrice.toInt() ?? 2499}',
                      tag: '★ Best Value',
                      color: AppColors.primary,
                      bgColor: AppColors.primaryContainer,
                      isHighlighted: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTierCard(
                      title: 'Premium Heritage',
                      price: '₹${pricing?.premiumPrice.toInt() ?? 2800}',
                      tag: 'Boutique',
                      color: const Color(0xFF8B5CF6),
                      bgColor: const Color(0xFFEDE9FE),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              CustomButton(
                text: 'Apply Price & Preview Listing 🚀',
                onPressed: () {
                  final recPrice = pricing?.recommendedPrice ?? 2499;
                  final raw = pricing?.rawMaterialCost ?? 800;
                  final prod = pricing?.productionCost ?? 500;
                  final other = pricing?.otherCost ?? 200;
                  final total = pricing?.totalCost ?? 1500;

                  context.push(
                    '/product-form?price=$recPrice&raw=$raw&prod=$prod&other=$other&total=$total&category=${Uri.encodeComponent(widget.initialData['category'] ?? "Textile")}&name=${Uri.encodeComponent(widget.initialData['name'] ?? "")}&desc=${Uri.encodeComponent(widget.initialData['desc'] ?? "")}&material=${Uri.encodeComponent(widget.initialData['material'] ?? "")}&craft=${Uri.encodeComponent(widget.initialData['craft'] ?? "")}',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostInput({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            decoration: const InputDecoration(
              prefixText: '₹ ',
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTierCard({
    required String title,
    required String price,
    required String tag,
    required Color color,
    required Color bgColor,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isHighlighted ? AppColors.primary : AppColors.surfaceBorder,
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    tag,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isHighlighted
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
