import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'published':
        bg = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        label = 'Published';
        break;
      case 'ready':
        bg = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        label = 'Ready';
        break;
      case 'draft':
        bg = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        label = 'Draft';
        break;
      case 'out_of_stock':
        bg = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        label = 'Out of Stock';
        break;
      case 'pending':
        bg = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
        label = 'Pending';
        break;
      case 'processing':
        bg = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF3730A3);
        label = 'Processing';
        break;
      case 'shipped':
        bg = const Color(0xFFEDE9FE);
        textColor = const Color(0xFF5B21B6);
        label = 'Shipped';
        break;
      case 'delivered':
        bg = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        label = 'Delivered';
        break;
      case 'cancelled':
        bg = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF4B5563);
        label = 'Cancelled';
        break;
      default:
        bg = AppColors.surfaceMuted;
        textColor = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
