import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/custom_button.dart';
import 'image_studio_provider.dart';

class ImageStudioScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const ImageStudioScreen({super.key, required this.imagePath});

  @override
  ConsumerState<ImageStudioScreen> createState() => _ImageStudioScreenState();
}

class _ImageStudioScreenState extends ConsumerState<ImageStudioScreen> {
  bool _showAfter = true;

  @override
  Widget build(BuildContext context) {
    final studioState = ref.watch(imageStudioProvider(widget.imagePath));
    final notifier = ref.read(imageStudioProvider(widget.imagePath).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Image Studio 📸'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Before / After Image Card with Interactive Toggle
              Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: AppShadows.elevated,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Active View (Before or After)
                      if (_showAfter && studioState.enhancedImageUrl != null)
                        _buildEnhancedImage(studioState.enhancedImageUrl!)
                      else
                        _buildOriginalImage(),

                      // Loading Overlay during enhancement
                      if (studioState.isProcessing)
                        Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 12),
                                Text(
                                  'AI is improving your product photo...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Before / After Switch Pill
                      Positioned(
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildToggleOption(
                                label: 'Before / मूल',
                                isSelected: !_showAfter,
                                onTap: () => setState(() => _showAfter = false),
                              ),
                              _buildToggleOption(
                                label: '✨ AI Studio / निखारा',
                                isSelected: _showAfter,
                                onTap: () => setState(() => _showAfter = true),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Photo Quality Score Badge
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Quality Score: ${studioState.qualityScore}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // AI Actions & Controls Section
              const Text(
                'AI Photo Enhancements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Remove Background (Clean Canvas)',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text(
                            'Isolates craft onto neutral studio backdrop',
                            style: TextStyle(fontSize: 12)),
                        value: studioState.removeBackground,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) =>
                            notifier.updateOption(removeBackground: val),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceBorder),
                      SwitchListTile(
                        title: const Text('Improve Lighting & Shadows',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text(
                            'Lifts dark areas and balances exposure',
                            style: TextStyle(fontSize: 12)),
                        value: studioState.enhanceLighting,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) =>
                            notifier.updateOption(enhanceLighting: val),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceBorder),
                      SwitchListTile(
                        title: const Text('Enhance Natural Colors',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text(
                            'Deepens organic dyes, textiles & wood grains',
                            style: TextStyle(fontSize: 12)),
                        value: studioState.enhanceColors,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) =>
                            notifier.updateOption(enhanceColors: val),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceBorder),
                      SwitchListTile(
                        title: const Text('E-Commerce 1:1 Square Crop',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text(
                            'Standard 1000x1000 resolution for marketplaces',
                            style: TextStyle(fontSize: 12)),
                        value: studioState.eCommerceCrop,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) =>
                            notifier.updateOption(eCommerceCrop: val),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Applied Corrections Diagnosis Card
              if (studioState.appliedCorrections.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              color: Color(0xFF2563EB), size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'AI Diagnosis & Applied Fixes',
                              style: TextStyle(
                                color: Color(0xFF1E40AF),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...studioState.appliedCorrections.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(Icons.check_circle_rounded,
                                    color: Color(0xFF2563EB), size: 14),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  c,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1E3A8A),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Continue Button
              CustomButton(
                text: _showAfter
                    ? 'Use AI Studio Photo / आगे बढ़ें'
                    : 'Use Original Photo / मूल फोटो के साथ आगे बढ़ें',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  final finalImg = _showAfter
                      ? (studioState.enhancedImageUrl ?? widget.imagePath)
                      : widget.imagePath;
                  context.push(
                      '/product-form?image=${Uri.encodeComponent(finalImg)}');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedImage(String url) {
    if (url.startsWith('data:image')) {
      final commaIdx = url.indexOf(',');
      if (commaIdx != -1) {
        final bytes = base64Decode(url.substring(commaIdx + 1));
        return Image.memory(
          bytes,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        );
      }
    }
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        errorWidget: (_, __, ___) => _buildOriginalImage(),
      );
    }
    return _buildOriginalImage();
  }

  Widget _buildOriginalImage() {
    if (widget.imagePath.startsWith('data:image')) {
      final commaIdx = widget.imagePath.indexOf(',');
      if (commaIdx != -1) {
        final bytes = base64Decode(widget.imagePath.substring(commaIdx + 1));
        return Image.memory(
          bytes,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        );
      }
    }
    if (!kIsWeb && File(widget.imagePath).existsSync()) {
      return Image.file(
        File(widget.imagePath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    }
    if (widget.imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: widget.imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    }
    return Container(
      color: AppColors.surfaceMuted,
      child: const Center(
        child: Icon(Icons.image, size: 64, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
