import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/localization/app_localizations.dart';

class AddProductHubScreen extends StatelessWidget {
  const AddProductHubScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );

    if (file != null) {
      final bytes = await file.readAsBytes();
      final dataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      if (context.mounted) {
        context.push('/image-studio?path=${Uri.encodeComponent(dataUri)}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Product'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.howToAdd,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose how you would like to digitize your craft creation',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 1. Take Photo
              _buildHubOption(
                context,
                title: loc.takePhoto,
                subtitle:
                    'Capture craft image with camera for AI auto enhancement & studio lighting',
                icon: Icons.camera_alt_rounded,
                color: AppColors.primary,
                gradient: const [AppColors.primary, AppColors.primaryLight],
                onTap: () => _pickImage(context, ImageSource.camera),
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Choose from Gallery
              _buildHubOption(
                context,
                title: loc.chooseGallery,
                subtitle:
                    'Upload existing photo from your phone gallery to optimize',
                icon: Icons.photo_library_rounded,
                color: AppColors.secondary,
                gradient: const [AppColors.secondary, AppColors.secondaryLight],
                onTap: () => _pickImage(context, ImageSource.gallery),
              ),
              const SizedBox(height: AppSpacing.md),

              // 3. Voice Description
              _buildHubOption(
                context,
                title: loc.describeVoice,
                subtitle:
                    'Speak in Hindi, Bengali, Tamil, etc. AI writes full catalog & SEO copy',
                icon: Icons.mic_rounded,
                color: const Color(0xFF059669),
                gradient: const [Color(0xFF059669), Color(0xFF10B981)],
                badge: '✨ Multilingual AI',
                onTap: () => context.push('/voice-catalog'),
              ),
              const SizedBox(height: AppSpacing.md),

              // 4. Enter Manually
              _buildHubOption(
                context,
                title: loc.enterManually,
                subtitle:
                    'Type product details, materials, costs, and pricing directly',
                icon: Icons.edit_note_rounded,
                color: const Color(0xFF7C3AED),
                gradient: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                onTap: () => context.push('/product-form'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHubOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Color(0xFF065F46),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
