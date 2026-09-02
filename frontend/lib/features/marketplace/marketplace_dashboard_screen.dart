import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/status_badge.dart';
import 'marketplace_provider.dart';

class MarketplaceDashboardScreen extends ConsumerWidget {
  const MarketplaceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketplaceProvider);
    final stats = state.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Marketplace Network 🌐'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(marketplaceProvider.notifier).fetchListings(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(marketplaceProvider.notifier).fetchListings(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Summary Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Total Listings',
                      value:
                          '${stats['totalListings'] ?? state.listings.length}',
                      icon: Icons.storefront_rounded,
                      color: AppColors.primary,
                      bgColor: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Active Listings',
                      value:
                          '${stats['activeListings'] ?? state.listings.length}',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                      bgColor: const Color(0xFFD1FAE5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'ONDC Network',
                      value:
                          '${stats['ondcCount'] ?? (state.listings.length / 2).toInt()}',
                      icon: Icons.hub_rounded,
                      color: const Color(0xFF2563EB),
                      bgColor: const Color(0xFFEFF6FF),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'GeM Network',
                      value:
                          '${stats['gemCount'] ?? (state.listings.length / 2).toInt()}',
                      icon: Icons.account_balance_rounded,
                      color: const Color(0xFF059669),
                      bgColor: const Color(0xFFECFDF5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Marketplace Channels Status
              const Text(
                'Connected Channel Integrations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              _buildChannelStatus(
                name: 'ONDC (Open Network for Digital Commerce)',
                protocol: 'Beckn Protocol v1.2 (Simulated)',
                status: 'Connected • Demo Ready',
                icon: Icons.hub_rounded,
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildChannelStatus(
                name: 'GeM (Government e-Marketplace)',
                protocol: 'GeM Catalog Integration (Simulated)',
                status: 'Connected • Demo Ready',
                icon: Icons.account_balance_rounded,
                color: const Color(0xFF059669),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Recent Active Listings List
              const Text(
                'Live Marketplace Listings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              if (state.isLoading)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ))
              else if (state.listings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: const Center(
                    child: Text('No marketplace listings published yet.'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.listings.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = state.listings[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
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
                                  '${item.marketplace} • ${item.marketplaceCategory}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ID: ${item.listingId}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: item.status),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelStatus({
    required String name,
    required String protocol,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text(protocol,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              status,
              style: const TextStyle(
                  color: Color(0xFF065F46),
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
