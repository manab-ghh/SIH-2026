import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/services/gemini_description_service.dart';
import '../../core/services/hf_background_removal_service.dart';
import '../../core/services/voice_input_service.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../shared/models/product_model.dart';
import 'product_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;
  final Map<String, dynamic> queryParams;

  const ProductFormScreen(
      {super.key, this.productId, this.queryParams = const {}});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _materialController;
  late TextEditingController _craftTypeController;
  late TextEditingController _colorController;
  late TextEditingController _sizeController;
  late TextEditingController _quantityController;
  late TextEditingController _rawCostController;
  late TextEditingController _prodCostController;
  late TextEditingController _otherCostController;
  late TextEditingController _priceController;
  late TextEditingController _craftStoryController;

  String _category = 'Textile';
  String _imageUrl = '';
  Uint8List? _pickedImageBytes;
  Uint8List? _bgRemovedBytes;
  bool _isRemovingBg = false;
  bool _isUsingBgRemoved = false;
  bool _isSaving = false;

  final HfBackgroundRemovalService _bgRemovalService =
      HfBackgroundRemovalService();
  final GeminiDescriptionService _geminiService = GeminiDescriptionService();
  final VoiceInputService _voiceService = VoiceInputService();

  final List<String> _categories = [
    'Textile',
    'Pottery',
    'Jewelry',
    'Woodwork',
    'Metalware',
    'Painting',
    'Leatherwork',
    'BambooCane',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final q = widget.queryParams;

    _nameController = TextEditingController(text: q['name'] ?? '');
    _descController = TextEditingController(text: q['desc'] ?? '');
    _materialController = TextEditingController(text: q['material'] ?? '');
    _craftTypeController = TextEditingController(text: q['craft'] ?? '');
    _colorController =
        TextEditingController(text: q['color'] ?? 'Indigo & Ochre');
    _sizeController = TextEditingController(text: q['size'] ?? 'Standard');
    _quantityController = TextEditingController(text: q['quantity'] ?? '5');
    _rawCostController = TextEditingController(text: q['raw'] ?? '800');
    _prodCostController = TextEditingController(text: q['prod'] ?? '500');
    _otherCostController = TextEditingController(text: q['other'] ?? '200');
    _priceController = TextEditingController(text: q['price'] ?? '2499');
    _craftStoryController = TextEditingController(
      text: q['story'] ??
          'Made by Hand. Made With Heritage. Every piece carries the skill and tradition of India’s artisan communities.',
    );

    _category = q['category'] ?? 'Textile';
    _imageUrl = q['image'] ??
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800';

    _nameController.addListener(() => setState(() {}));
    _materialController.addListener(() => setState(() {}));
    _craftTypeController.addListener(() => setState(() {}));

    _loadExistingProduct();
  }

  Future<void> _loadExistingProduct() async {
    if (widget.productId != null) {
      final repository = ref.read(productRepositoryProvider);
      try {
        final prod = await repository.getProductById(widget.productId!);
        setState(() {
          _nameController.text = prod.name;
          _descController.text = prod.description;
          _materialController.text = prod.material;
          _craftTypeController.text = prod.craftType;
          _colorController.text = prod.color;
          _sizeController.text = prod.size;
          _quantityController.text = prod.quantity.toString();
          _rawCostController.text = prod.rawMaterialCost.toInt().toString();
          _prodCostController.text = prod.productionCost.toInt().toString();
          _otherCostController.text = prod.otherCost.toInt().toString();
          _priceController.text = prod.recommendedPrice.toInt().toString();
          _craftStoryController.text = prod.craftStory;
          _category = prod.category;
          if (prod.images.isNotEmpty) {
            _imageUrl = prod.images.first;
          }
        });
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _materialController.dispose();
    _craftTypeController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _quantityController.dispose();
    _rawCostController.dispose();
    _prodCostController.dispose();
    _otherCostController.dispose();
    _priceController.dispose();
    _craftStoryController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // FEATURE 1: AI Background Removal (briaai/RMBG-2.0)
  // ---------------------------------------------------------------------------

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Add Product Photo / उत्पाद की फोटो जोड़ें',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: const Text('Take Photo with Camera / कैमरा से फोटो खींचें'),
                subtitle: const Text('Click fresh photo of your craft item'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickNewImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.photo_library_rounded, color: Color(0xFF2563EB)),
                ),
                title: const Text('Choose from Gallery / गैलरी से चुनें'),
                subtitle: const Text('Upload existing craft image from device'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickNewImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickNewImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1400,
        maxHeight: 1400,
        imageQuality: 88,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _pickedImageBytes = bytes;
          _imageUrl = base64String;
          _bgRemovedBytes = null;
          _isUsingBgRemoved = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📸 Photo added successfully!'),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  Future<void> _handleRemoveBackground() async {
    if ((_imageUrl.isEmpty && _pickedImageBytes == null) || _isRemovingBg) return;

    setState(() => _isRemovingBg = true);

    try {
      final result = await _bgRemovalService.removeBackground(
        imagePath: _imageUrl,
        rawBytes: _pickedImageBytes,
      );

      if (!mounted) return;

      if (result.success && result.resultImageUrl != null) {
        setState(() {
          _bgRemovedBytes = result.imageBytes;
          _isRemovingBg = false;
          _isUsingBgRemoved = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Background removed using RMBG-2.0!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() => _isRemovingBg = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ??
                'Unable to remove the background. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isRemovingBg = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to remove the background. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _restoreOriginalImage() {
    setState(() {
      _isUsingBgRemoved = false;
      _bgRemovedBytes = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📸 Original photo restored')),
    );
  }

  // ---------------------------------------------------------------------------
  // FEATURE 2: AI Voice-Assisted Product Description (Gemini)
  // ---------------------------------------------------------------------------

  void _openVoiceDescriptionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VoiceAssistantBottomSheet(
        productName: _nameController.text.trim(),
        category: _category,
        material: _materialController.text.trim(),
        craftType: _craftTypeController.text.trim(),
        color: _colorController.text.trim(),
        size: _sizeController.text.trim(),
        existingDescription: _descController.text.trim(),
        geminiService: _geminiService,
        voiceService: _voiceService,
        onApplyDescription: (newDesc, newStory) {
          _handleApplyGeneratedDescription(newDesc, newStory);
        },
      ),
    );
  }

  void _handleApplyGeneratedDescription(String newDesc, String? newStory) {
    final existing = _descController.text.trim();

    if (existing.isNotEmpty && existing != newDesc) {
      // Existing Description Protection Dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Update Description?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your description field already contains text. How would you like to apply the AI description?',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Current: "${existing.length > 70 ? "${existing.substring(0, 70)}..." : existing}"',
                  style: const TextStyle(
                      fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Improve / Append
                setState(() {
                  _descController.text = '$existing\n\n$newDesc';
                  if (newStory != null && newStory.isNotEmpty) {
                    _craftStoryController.text = newStory;
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appended AI description!')),
                );
              },
              child: const Text('Append / जोड़ें'),
            ),
            ElevatedButton(
              onPressed: () {
                // Replace
                setState(() {
                  _descController.text = newDesc;
                  if (newStory != null && newStory.isNotEmpty) {
                    _craftStoryController.text = newStory;
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Replaced with AI description!')),
                );
              },
              child: const Text('Replace / बदलें'),
            ),
          ],
        ),
      );
    } else {
      // Direct apply when empty
      setState(() {
        _descController.text = newDesc;
        if (newStory != null && newStory.isNotEmpty) {
          _craftStoryController.text = newStory;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✨ AI Description applied successfully!')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SAVE / PUBLISH
  // ---------------------------------------------------------------------------

  Future<void> _saveProduct({bool publish = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final raw = double.tryParse(_rawCostController.text) ?? 0;
    final prodCost = double.tryParse(_prodCostController.text) ?? 0;
    final other = double.tryParse(_otherCostController.text) ?? 0;
    final total = raw + prodCost + other;
    final price = double.tryParse(_priceController.text) ?? (total * 1.6);
    final qty = int.tryParse(_quantityController.text) ?? 1;

    final data = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'descriptionHindi': _descController.text.trim(),
      'category': _category,
      'material': _materialController.text.trim(),
      'craftType': _craftTypeController.text.trim(),
      'color': _colorController.text.trim(),
      'size': _sizeController.text.trim(),
      'quantity': qty,
      'rawMaterialCost': raw,
      'productionCost': prodCost,
      'otherCost': other,
      'totalCost': total,
      'recommendedPrice': price,
      'minimumPrice': (total * 1.3).roundToDouble(),
      'competitivePrice': (total * 1.5).roundToDouble(),
      'premiumPrice': (total * 1.9).roundToDouble(),
      'craftStory': _craftStoryController.text.trim(),
      'status': publish ? 'published' : 'draft',
      'images': [
        _isUsingBgRemoved && _bgRemovedBytes != null
            ? 'data:image/png;base64,${base64Encode(_bgRemovedBytes!)}'
            : (_pickedImageBytes != null
                ? 'data:image/jpeg;base64,${base64Encode(_pickedImageBytes!)}'
                : (_imageUrl.isNotEmpty
                    ? _imageUrl
                    : 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800')),
      ],
    };

    final repository = ref.read(productRepositoryProvider);
    try {
      ProductModel saved;
      if (widget.productId != null) {
        saved = await repository.updateProduct(widget.productId!, data);
      } else {
        saved = await repository.createProduct(data);
      }

      await ref.read(productListProvider.notifier).fetchProducts();

      if (mounted) {
        context.push('/product-preview/${saved.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product Details' : 'Product Information'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 0. Product Image & AI Background Removal Section
                _buildSectionHeader(
                    'Product Photo & AI Studio / फोटो और AI संपादन',
                    Icons.photo_camera_back_outlined),
                _buildProductImageSection(),

                const SizedBox(height: AppSpacing.lg),

                // 1. Basic Details
                _buildSectionHeader('1. Basic Details / बुनियादी जानकारी',
                    Icons.info_outline_rounded),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Product Name / उत्पाद का नाम *',
                        hint: 'e.g. Handwoven Cotton Saree',
                        controller: _nameController,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Name required'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Craft Category / श्रेणी *',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _category,
                            items: _categories.map((c) {
                              return DropdownMenuItem(value: c, child: Text(c));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _category = val);
                            },
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CustomTextField(
                        label: 'Available Quantity in Stock / उपलब्ध स्टॉक *',
                        hint: '5',
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 2. Craft Specifications with Voice Assistant
                _buildSectionHeader(
                    '2. Craft Specifications & AI Description / शिल्प विवरण',
                    Icons.brush_outlined),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: 'Material / प्रयुक्त सामग्री',
                        hint: 'e.g. 100% Organic Handloom Cotton',
                        controller: _materialController,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CustomTextField(
                        label: 'Craft Technique / शिल्प कला',
                        hint: 'e.g. Traditional Pit Loom Weaving',
                        controller: _craftTypeController,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Color Palette',
                              hint: 'Indigo Blue',
                              controller: _colorController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              label: 'Dimensions / Size',
                              hint: '6.3 Meters',
                              controller: _sizeController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Description Field Header with Voice Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Product Description / उत्पाद विवरण *',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _openVoiceDescriptionModal,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.mic_rounded,
                                      size: 16, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text(
                                    '🎤 Voice AI (Whisper)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        label: 'Detailed Description / विस्तृत विवरण',
                        hint:
                            'Describe your handicraft or use the 🎤 Voice AI button to speak in Hindi/English...',
                        controller: _descController,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 3. Costs & Pricing
                _buildSectionHeader('3. Cost & Pricing / लागत और मूल्य',
                    Icons.currency_rupee_rounded),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Raw Material (₹)',
                              hint: '800',
                              controller: _rawCostController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              label: 'Artisan Labor (₹)',
                              hint: '500',
                              controller: _prodCostController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CustomTextField(
                        label: 'Selling Price / विक्रय मूल्य (₹) *',
                        hint: '2499',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Price required'
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 4. Craft Story
                _buildSectionHeader('4. Heritage Story / शिल्प धरोहर की कहानी',
                    Icons.auto_stories_outlined),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: CustomTextField(
                    label: 'Craft Story for Buyers',
                    controller: _craftStoryController,
                    maxLines: 3,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Action Buttons
                CustomButton(
                  text: 'Save & Preview Listing / पूर्वावलोकन 🚀',
                  isLoading: _isSaving,
                  onPressed: () => _saveProduct(publish: false),
                ),
                const SizedBox(height: AppSpacing.sm),
                CustomButton(
                  text: 'Direct Publish / तुरंत प्रकाशित करें',
                  isOutlined: true,
                  isLoading: _isSaving,
                  onPressed: () => _saveProduct(publish: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImageSection() {
    final hasImage = _pickedImageBytes != null || _imageUrl.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          // Image Preview Container
          Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _isUsingBgRemoved && _bgRemovedBytes != null
                    ? AppColors.success
                    : AppColors.surfaceBorder,
                width: _isUsingBgRemoved && _bgRemovedBytes != null ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Checkerboard transparent background when background is removed
                  if (_isUsingBgRemoved && _bgRemovedBytes != null)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CheckerboardPainter(),
                      ),
                    ),

                  _buildImageView(),

                  // Loading Overlay for Background Removal
                  if (_isRemovingBg)
                    Container(
                      color: Colors.black.withValues(alpha: 0.65),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 12),
                            Text(
                              '✨ Removing background...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Preserving fine craft details (RMBG-2.0)...',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Status Badge for BG Removal
                  if (hasImage && !_isRemovingBg && _isUsingBgRemoved && _bgRemovedBytes != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'BG REMOVED (RMBG-2.0)',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Actions Below Image Preview
          if (_isUsingBgRemoved && _bgRemovedBytes != null) ...[
            // Mode: BG removed is active, offer option to switch back to original or change photo
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _restoreOriginalImage,
                    icon: const Icon(Icons.photo_rounded, size: 16),
                    label: const Text('Keep Original Photo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showImagePickerSheet,
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: const Text('Change Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Mode: Original Photo as-is. User can choose new photo or optionally remove BG
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showImagePickerSheet,
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: Text(hasImage ? 'Change Photo' : 'Take / Upload Photo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasImage && !_isRemovingBg
                        ? _handleRemoveBackground
                        : null,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: const Text('✨ Remove Background'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageView() {
    if (_isUsingBgRemoved && _bgRemovedBytes != null) {
      return Image.memory(
        _bgRemovedBytes!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (_pickedImageBytes != null) {
      return Image.memory(
        _pickedImageBytes!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (_imageUrl.startsWith('data:image')) {
      final commaIdx = _imageUrl.indexOf(',');
      if (commaIdx != -1) {
        final bytes = base64Decode(_imageUrl.substring(commaIdx + 1));
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        );
      }
    }
    if (!kIsWeb && _imageUrl.isNotEmpty && File(_imageUrl).existsSync()) {
      return Image.file(
        File(_imageUrl),
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (_imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: _imageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        errorWidget: (_, __, ___) => const Center(
          child: Icon(Icons.image, size: 48, color: AppColors.textMuted),
        ),
      );
    }
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 44, color: AppColors.textMuted),
          SizedBox(height: 8),
          Text(
            'Take photo or choose from gallery\n(फोटो खींचें या गैलरी से चुनें)',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Interactive Voice Assistant Bottom Sheet Widget (Gemini)
// -----------------------------------------------------------------------------

class _VoiceAssistantBottomSheet extends StatefulWidget {
  final String productName;
  final String category;
  final String material;
  final String craftType;
  final String color;
  final String size;
  final String existingDescription;
  final GeminiDescriptionService geminiService;
  final VoiceInputService voiceService;
  final void Function(String newDescription, String? newStory)
      onApplyDescription;

  const _VoiceAssistantBottomSheet({
    required this.productName,
    required this.category,
    required this.material,
    required this.craftType,
    required this.color,
    required this.size,
    required this.existingDescription,
    required this.geminiService,
    required this.voiceService,
    required this.onApplyDescription,
  });

  @override
  State<_VoiceAssistantBottomSheet> createState() =>
      _VoiceAssistantBottomSheetState();
}

class _VoiceAssistantBottomSheetState extends State<_VoiceAssistantBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _micPulseController;
  final TextEditingController _transcriptController = TextEditingController();
  String _selectedLang = 'hi';
  bool _isListening = false;
  bool _isGenerating = false;
  String? _generatedDescription;
  String? _generatedStory;
  List<String> _suggestedKeywords = [];
  String? _errorMessage;

  final List<Map<String, String>> _languages = [
    {'code': 'hi', 'name': 'हिंदी'},
    {'code': 'en', 'name': 'English'},
    {'code': 'bn', 'name': 'বাংলা'},
    {'code': 'ta', 'name': 'தமிழ்'},
    {'code': 'te', 'name': 'తెలుగు'},
    {'code': 'mr', 'name': 'मराठी'},
  ];

  @override
  void initState() {
    super.initState();
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Auto-start simulated speech recognition when opened
    _startVoiceInput();
  }

  @override
  void dispose() {
    _micPulseController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _startVoiceInput() async {
    setState(() {
      _isListening = true;
      _errorMessage = null;
    });

    final transcript =
        await widget.voiceService.startListening(languageCode: _selectedLang);

    if (mounted) {
      setState(() {
        _isListening = false;
        _transcriptController.text = transcript;
      });
    }
  }

  Future<void> _generateWithGemini() async {
    final text = _transcriptController.text.trim();
    if (text.isEmpty) {
      setState(() =>
          _errorMessage = "Please speak or enter some product details first.");
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      GeminiDescriptionResult result;
      if (widget.existingDescription.isNotEmpty) {
        result = await widget.geminiService.improveDescription(
          existingDescription: widget.existingDescription,
          additionalVoiceNotes: text,
          productName: widget.productName,
          material: widget.material,
          craftType: widget.craftType,
        );
      } else {
        result = await widget.geminiService.generateDescription(
          voiceTranscript: text,
          productName: widget.productName,
          category: widget.category,
          material: widget.material,
          craftType: widget.craftType,
          color: widget.color,
          size: widget.size,
          language: _selectedLang,
        );
      }

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generatedDescription = result.description;
          _generatedStory = result.craftStory;
          _suggestedKeywords = result.suggestedKeywords;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _errorMessage =
              "Unable to generate description with Gemini. Please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Handle pill
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Modal Header (Overflow Safe)
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(Icons.mic_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'AI Voice Assistant',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'openai/whisper-large-v3-turbo + Gemini',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Language Selector Chips
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _languages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final lang = _languages[index];
                  final isSelected = _selectedLang == lang['code'];
                  return ChoiceChip(
                    label: Text(lang['name']!),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedLang = lang['code']!);
                        _startVoiceInput();
                      }
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // Pulsing Microphone Action Circle
            GestureDetector(
              onTap: _isListening || _isGenerating ? null : _startVoiceInput,
              child: AnimatedBuilder(
                animation: _micPulseController,
                builder: (context, child) {
                  final scale = _isListening
                      ? 1.0 + (_micPulseController.value * 0.15)
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isListening
                              ? [AppColors.error, const Color(0xFFDC2626)]
                              : [AppColors.primary, AppColors.secondary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening
                                    ? AppColors.error
                                    : AppColors.primary)
                                .withValues(alpha: 0.35),
                            blurRadius: _isListening ? 24 : 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening
                            ? Icons.graphic_eq_rounded
                            : Icons.mic_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Text(
              _isListening
                  ? '🎙️ Listening... Speak about your craft / बोलकर बताएं'
                  : _isGenerating
                      ? '✨ Gemini is creating product description...'
                      : 'Tap mic or pick a sample prompt below / नीचे उदाहरण चुनें',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _isListening ? AppColors.error : AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            // Quick Voice Prompts Carousel for Current Language
            Builder(
              builder: (context) {
                final phrases =
                    VoiceInputService.sampleCraftPhrases[_selectedLang] ??
                        VoiceInputService.sampleCraftPhrases['hi']!;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: phrases.map((phrase) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          avatar: const Icon(Icons.record_voice_over_rounded,
                              size: 14, color: AppColors.primary),
                          label: Text(
                            phrase.length > 36
                                ? '${phrase.substring(0, 36)}...'
                                : phrase,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textPrimary),
                          ),
                          backgroundColor: AppColors.primaryContainer,
                          onPressed: () {
                            setState(() {
                              _transcriptController.text = phrase;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Editable Transcript Text Area
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recognized Speech / बोला गया विवरण (Editable ✏️):',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary),
                      ),
                      if (_transcriptController.text.isNotEmpty)
                        InkWell(
                          onTap: () =>
                              setState(() => _transcriptController.clear()),
                          child: const Text('Clear',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _transcriptController,
                    maxLines: 3,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          'Your spoken handicraft notes will appear here. You can also type or edit...',
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),

            const SizedBox(height: 12),

            // AI Generated Result Box (if generated)
            if (_generatedDescription != null) ...[
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
                            color: Color(0xFF2563EB), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Gemini Generated Marketplace Description:',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _generatedDescription!,
                      style: const TextStyle(
                          fontSize: 13, height: 1.45, color: Color(0xFF1E3A8A)),
                    ),
                    if (_suggestedKeywords.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: _suggestedKeywords.map((kw) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: const Color(0xFF93C5FD)),
                            ),
                            child: Text(kw,
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFF1D4ED8))),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action Controls: [ 🎤 Speak ] [ ✨ Generate with AI ]
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isListening || _isGenerating ? null : _startVoiceInput,
                    icon: const Icon(Icons.mic_rounded, size: 16),
                    label: Text(_isListening ? 'Listening...' : '🎤 Speak'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateWithGemini,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: Text(_generatedDescription != null
                        ? '🔄 Regenerate'
                        : '✨ Generate with AI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            if (_generatedDescription != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onApplyDescription(
                        _generatedDescription!, _generatedStory);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_rounded),
                  label:
                      const Text('Apply to Product Description / लागू करें ✨'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double cellSize = 12.0;
    final paint1 = Paint()..color = const Color(0xFFF8FAFC);
    final paint2 = Paint()..color = const Color(0xFFE2E8F0);

    for (double y = 0; y < size.height; y += cellSize) {
      for (double x = 0; x < size.width; x += cellSize) {
        final isEven =
            (((x / cellSize).floor() + (y / cellSize).floor()) % 2 == 0);
        canvas.drawRect(
          Rect.fromLTWH(x, y, cellSize, cellSize),
          isEven ? paint1 : paint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
