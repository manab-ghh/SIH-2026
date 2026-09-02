import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/localization/language_provider.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../auth/auth_provider.dart';
import '../products/product_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Uint8List? _imageBytes;
  bool _isUploadingImage = false;

  // ── Image Picker ────────────────────────────────────────────────────────────

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 600,
        maxHeight: 600,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final mime = (ext == 'png') ? 'image/png' : 'image/jpeg';
      final base64Str = base64Encode(bytes);
      final dataUri = 'data:$mime;base64,$base64Str';

      setState(() {
        _imageBytes = bytes;
        _isUploadingImage = true;
      });

      await ref.read(authProvider.notifier).updateProfile(profileImage: dataUri);

      if (mounted) setState(() => _isUploadingImage = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile photo updated!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md, horizontal: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const Text(
                'Change Profile Photo / फ़ोटो बदलें',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary),
                ),
                title: const Text('Take a Photo / कैमरे से',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Use your camera',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickProfileImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1, color: AppColors.surfaceBorder),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: Color(0xFF2563EB)),
                ),
                title: const Text('Choose from Gallery / गैलरी से',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pick from your photos',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickProfileImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  // ── Language Picker ─────────────────────────────────────────────────────────

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        final currentLocale = ref.watch(languageProvider);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select App Language / भाषा चुनें',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...supportedLanguages.map((lang) {
                  final isSelected = currentLocale.languageCode == lang.code;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${lang.nativeName} (${lang.name})',
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary)
                        : null,
                    onTap: () {
                      ref
                          .read(languageProvider.notifier)
                          .setLanguage(lang.code);
                      ref
                          .read(authProvider.notifier)
                          .updateProfile(preferredLanguage: lang.code);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Edit Profile Dialog ─────────────────────────────────────────────────────

  void _showEditProfileDialog() {
    final user = ref.read(authProvider).user;
    final nameController = TextEditingController(
        text: (user != null && user.name.isNotEmpty)
            ? user.name
            : 'Ramkishan Verma');
    final locationController = TextEditingController(
        text: (user != null && user.location.isNotEmpty)
            ? user.location
            : 'Varanasi, Uttar Pradesh');
    final specialtyController = TextEditingController(
        text: (user != null && user.craftSpecialty.isNotEmpty)
            ? user.craftSpecialty
            : 'Banarasi Handloom & Brocade Weaving');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Artisan Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                  label: 'Full Name / नाम', controller: nameController),
              const SizedBox(height: 12),
              CustomTextField(
                  label: 'Location / स्थान', controller: locationController),
              const SizedBox(height: 12),
              CustomTextField(
                  label: 'Craft Specialty / शिल्प',
                  controller: specialtyController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(authProvider.notifier).updateProfile(
                    name: nameController.text.trim(),
                    location: locationController.text.trim(),
                    craftSpecialty: specialtyController.text.trim(),
                  );
              if (context.mounted) {
                Navigator.pop(ctx);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('✅ Profile updated successfully!'),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Save Changes',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── About Dialog ────────────────────────────────────────────────────────────

  void _showAboutAppDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'ShilpSetu AI',
      applicationVersion: 'v1.0.0 (Production Release)',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('शिल्प',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      children: [
        const SizedBox(height: 12),
        const Text(
          'ShilpSetu AI ("आपके हुनर का डिजिटल साथी") is an AI-powered business manager built for Indian artisans, weavers, and craftsmen to effortlessly digitize handmade creations and connect with digital marketplaces.',
        ),
      ],
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final displayName = (user != null && user.name.isNotEmpty)
        ? user.name
        : 'Ramkishan Verma';
    final craftSpecialty = (user != null && user.craftSpecialty.isNotEmpty)
        ? user.craftSpecialty
        : 'Banarasi Handloom & Brocade Weaving';
    final location = (user != null && user.location.isNotEmpty)
        ? user.location
        : 'Varanasi, Uttar Pradesh';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Artisan Profile / प्रोफ़ाइल',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Refresh / ताज़ा करें',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(authProvider.notifier).checkAuthStatus();
              ref.read(productListProvider.notifier).fetchProducts();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authProvider.notifier).checkAuthStatus();
          await ref.read(productListProvider.notifier).fetchProducts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // ── Profile Card ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    // Tap avatar to change photo
                    GestureDetector(
                      onTap: _showImageSourceSheet,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryContainer,
                              border: Border.all(
                                  color: AppColors.primary, width: 2.5),
                            ),
                            child: ClipOval(
                              child: _isUploadingImage
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : _imageBytes != null
                                      ? Image.memory(
                                          _imageBytes!,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        )
                                      : (user != null &&
                                              user.profileImage.isNotEmpty)
                                          ? AppProductImage(
                                              imageUrl: user.profileImage,
                                              width: 90,
                                              height: 90,
                                              fit: BoxFit.cover,
                                            )
                                          : const Center(
                                              child: Icon(
                                                  Icons.person_rounded,
                                                  size: 50,
                                                  color: AppColors.primary),
                                            ),
                            ),
                          ),
                          // Camera badge overlay
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      craftSpecialty,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _showEditProfileDialog,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Profile / संपादन'),
                        ),
                        if (user == null)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () =>
                                ref.read(authProvider.notifier).demoLogin(),
                            icon: const Icon(Icons.login_rounded, size: 16),
                            label: const Text('Login Demo Profile'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Products & Inventory ──────────────────────────────────────
              Builder(
                builder: (context) {
                  final productState = ref.watch(productListProvider);
                  final products = productState.products;
                  final totalStockValue = products.fold<double>(
                      0, (sum, p) => sum + (p.recommendedPrice * p.quantity));

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.surfaceBorder),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory_2_rounded,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'My Products / मेरे उत्पाद (${products.length})',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 90,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    context.push('/add-product-hub'),
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('+ Add'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Mini KPI badges
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Listed Products',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary)),
                                    Text('${products.length}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Catalog Value',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary)),
                                    Text('₹${totalStockValue.toInt()}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        if (products.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                const Icon(Icons.storefront_outlined,
                                    size: 40, color: AppColors.textMuted),
                                const SizedBox(height: 8),
                                const Text(
                                  'No products added yet / अभी कोई उत्पाद नहीं है',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.push('/add-product-hub'),
                                  icon: const Icon(
                                      Icons.add_circle_outline,
                                      size: 16),
                                  label:
                                      const Text('Add Your First Product ✨'),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 16, color: AppColors.surfaceBorder),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final imageUrl = product.images.isNotEmpty
                                  ? product.images.first
                                  : '';

                              return InkWell(
                                onTap: () => context
                                    .push('/product-preview/${product.id}'),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      AppProductImage(
                                        imageUrl: imageUrl,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.sm),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 2,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .primaryContainer,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    product.category,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Stock: ${product.quantity}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₹${product.recommendedPrice.toInt()}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 14,
                                              color: AppColors.textSecondary),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Settings List ─────────────────────────────────────────────
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language_rounded,
                          color: AppColors.primary),
                      title: const Text('App Language / भाषा बदलें'),
                      subtitle: Text(
                          'Current: ${ref.watch(languageProvider).languageCode.toUpperCase()}'),
                      trailing:
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: _showLanguagePicker,
                    ),
                    const Divider(height: 1, color: AppColors.surfaceBorder),
                    ListTile(
                      leading: const Icon(Icons.hub_rounded,
                          color: Color(0xFF2563EB)),
                      title: const Text('Marketplace Network (ONDC & GeM)'),
                      subtitle: const Text('Connected • Demo Ready'),
                      trailing:
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () => context.push('/marketplace-dashboard'),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceBorder),
                    ListTile(
                      leading: const Icon(Icons.help_outline_rounded,
                          color: Color(0xFF059669)),
                      title: const Text('Help & Artisan Support'),
                      subtitle:
                          const Text('Call craft helpline: 1800-SHILP-AI'),
                      trailing:
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Support helpline: 1800-SHILP-AI (Toll Free)')),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.surfaceBorder),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded,
                          color: Color(0xFFD97706)),
                      title: const Text('About ShilpSetu AI'),
                      subtitle: const Text('Your AI Business Manager'),
                      trailing:
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: _showAboutAppDialog,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Logout ────────────────────────────────────────────────────
              CustomButton(
                text: 'Logout / लॉगआउट',
                isOutlined: true,
                backgroundColor: AppColors.error,
                textColor: AppColors.error,
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
