import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/custom_button.dart';
import 'marketplace_provider.dart';

class MarketplacePublishScreen extends ConsumerStatefulWidget {
  final String productId;

  const MarketplacePublishScreen({super.key, required this.productId});

  @override
  ConsumerState<MarketplacePublishScreen> createState() =>
      _MarketplacePublishScreenState();
}

class _MarketplacePublishScreenState
    extends ConsumerState<MarketplacePublishScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(marketplaceProvider.notifier).resetPublishState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceProvider);
    final isDone = state.publishStep == 4;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isDone ? 'Published Successfully 🎉' : 'Publish Product'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: isDone ? _buildSuccessView(state) : _buildPublishView(state),
        ),
      ),
    );
  }

  Widget _buildPublishView(MarketplaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ready to Sell? 🚀',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your product has passed all AI preparation checks',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Checklist Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: const Column(
            children: [
              _ChecklistRow(
                  text: 'Product photo optimized (AI Studio Studio Canvas)'),
              SizedBox(height: 8),
              _ChecklistRow(
                  text: 'Bilingual product description generated (EN & HI)'),
              SizedBox(height: 8),
              _ChecklistRow(
                  text: 'Smart fair pricing recommended & margin checked'),
              SizedBox(height: 8),
              _ChecklistRow(
                  text: 'Craft heritage metadata & SEO tags attached'),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Marketplaces Selection
        const Text(
          'Select Target Marketplaces',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ONDC Card
        _buildMarketplaceCard(
          title: 'ONDC (Open Network for Digital Commerce)',
          subtitle: 'Enables discoverability across all Indian buyer apps',
          status: 'Demo Ready',
          icon: Icons.hub_rounded,
          color: const Color(0xFF2563EB),
          bgColor: const Color(0xFFEFF6FF),
        ),
        const SizedBox(height: AppSpacing.sm),

        // GeM Card
        _buildMarketplaceCard(
          title: 'GeM (Government e-Marketplace)',
          subtitle: 'Direct procurement channel for government entities & PSUs',
          status: 'Demo Ready',
          icon: Icons.account_balance_rounded,
          color: const Color(0xFF059669),
          bgColor: const Color(0xFFECFDF5),
        ),

        const SizedBox(height: AppSpacing.md),

        // Simulation Progress Status if in progress
        if (state.isPublishing || state.publishStep > 0) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.primary),
            ),
            child: Column(
              children: [
                const LinearProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  state.publishStep == 1
                      ? '1/3 Preparing digital catalog listing...'
                      : state.publishStep == 2
                          ? '2/3 Validating product with marketplace schema...'
                          : '3/3 Registering with ONDC & GeM networks...',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Disclaimer Notice
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Simulation / Demo: ONDC & GeM integrations are simulated for exhibition and prototype demonstration.',
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Publish Action Button
        CustomButton(
          text: 'Publish to Marketplaces / प्रकाशित करें 🎉',
          isLoading: state.isPublishing,
          onPressed: state.isPublishing
              ? null
              : () {
                  ref
                      .read(marketplaceProvider.notifier)
                      .publishProduct(widget.productId);
                },
        ),
      ],
    );
  }

  Widget _buildSuccessView(MarketplaceState state) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFFD1FAE5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: Color(0xFF059669), size: 54),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Product Published Successfully! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your craft listing is now live across simulated marketplace channels',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Generated Demo Listing IDs
        ...state.latestPublishedListings.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.marketplace == 'ONDC'
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    item.marketplace == 'ONDC'
                        ? Icons.hub_rounded
                        : Icons.account_balance_rounded,
                    color: item.marketplace == 'ONDC'
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.marketplace} Listing Active',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Listing ID: ${item.listingId}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text(
                    'Published ✓',
                    style: TextStyle(
                      color: Color(0xFF065F46),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: const Text(
            'Demo marketplace listing. No real financial or governmental marketplace transaction has been performed.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        CustomButton(
          text: 'View Marketplace Dashboard 📊',
          onPressed: () => context.push('/marketplace-dashboard'),
        ),
        const SizedBox(height: AppSpacing.sm),
        CustomButton(
          text: 'Back to Home / मुख्यपृष्ठ',
          isOutlined: true,
          onPressed: () => context.go('/home'),
        ),
      ],
    );
  }

  Widget _buildMarketplaceCard({
    required String title,
    required String subtitle,
    required String status,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Color(0xFF065F46),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String text;

  const _ChecklistRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded,
            color: Color(0xFF059669), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF065F46),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
