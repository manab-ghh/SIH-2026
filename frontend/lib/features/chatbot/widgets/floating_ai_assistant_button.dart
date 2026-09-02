import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

class FloatingAiAssistantButton extends StatefulWidget {
  const FloatingAiAssistantButton({super.key});

  @override
  State<FloatingAiAssistantButton> createState() =>
      _FloatingAiAssistantButtonState();
}

class _FloatingAiAssistantButtonState extends State<FloatingAiAssistantButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = _pulseController.value * 8;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 10 + glow,
                spreadRadius: 1 + (_pulseController.value * 2),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: 'floating_ai_assistant_fab',
            onPressed: () => context.push('/chatbot'),
            backgroundColor: AppColors.primary,
            elevation: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.smart_toy_rounded,
                    color: Colors.white, size: 28),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
