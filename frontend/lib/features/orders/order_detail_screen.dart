import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../shared/models/order_model.dart';
import 'order_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isUpdating = false;

  void _advanceOrderStatus(OrderModel order) async {
    String? nextStatus;
    if (order.status == 'pending') {
      nextStatus = 'confirmed';
    } else if (order.status == 'confirmed') {
      nextStatus = 'processing';
    } else if (order.status == 'processing') {
      nextStatus = 'shipped';
    } else if (order.status == 'shipped') {
      nextStatus = 'delivered';
    }

    if (nextStatus != null) {
      setState(() => _isUpdating = true);
      await ref
          .read(orderProvider.notifier)
          .updateOrderStatus(order.id, nextStatus);
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final order = orderState.orders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => OrderModel(
        id: widget.orderId,
        orderNumber: 'SHL-10230',
        productId: '',
        productName: 'Handwoven Chanderi Saree',
        buyerName: 'Pooja Sharma',
        buyerPhone: '+91 98765 43210',
        price: 2499,
        totalAmount: 2499,
        status: 'processing',
        createdAt: DateTime.now(),
      ),
    );

    String? actionButtonText;
    if (order.status == 'pending') {
      actionButtonText = 'Confirm Order / ऑर्डर स्वीकारें';
    } else if (order.status == 'confirmed') {
      actionButtonText = 'Start Crafting & Packing';
    } else if (order.status == 'processing') {
      actionButtonText = 'Mark as Shipped 🚚';
    } else if (order.status == 'shipped') {
      actionButtonText = 'Mark as Delivered ✓';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(order.orderNumber),
      ),
      bottomNavigationBar: actionButtonText != null
          ? Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                    top: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: SafeArea(
                child: CustomButton(
                  text: actionButtonText,
                  isLoading: _isUpdating,
                  onPressed: () => _advanceOrderStatus(order),
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Placed on ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  StatusBadge(status: order.status),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Product Item Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  AppProductImage(
                    imageUrl: order.productImage,
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.productName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Qty: ${order.quantity}  •  Price: ₹${order.price.toInt()}',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ₹${order.totalAmount.toInt()}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Buyer & Shipping Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buyer & Delivery Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text('Customer: ${order.buyerName}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Phone: ${order.buyerPhone}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 6),
                  const Text('Delivery Address:',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  Text(
                    '${order.shippingAddress?['street'] ?? "42, Heritage Enclave"}\n${order.shippingAddress?['city'] ?? "Bengaluru"}, ${order.shippingAddress?['state'] ?? "Karnataka"} - ${order.shippingAddress?['postalCode'] ?? "560001"}',
                    style: const TextStyle(fontSize: 13, height: 1.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Order Timeline
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Progress Timeline',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  if (order.timeline.isEmpty)
                    const Text('No timeline recorded yet.',
                        style: TextStyle(color: AppColors.textSecondary))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.timeline.length,
                      itemBuilder: (context, idx) {
                        final item = order.timeline[idx];
                        final isLast = idx == order.timeline.length - 1;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: isLast
                                        ? AppColors.primary
                                        : AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                if (idx < order.timeline.length - 1)
                                  Container(
                                    width: 2,
                                    height: 36,
                                    color: AppColors.surfaceBorder,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.message,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.timestamp.day}/${item.timestamp.month} • ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
