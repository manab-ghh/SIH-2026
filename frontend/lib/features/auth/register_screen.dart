import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import 'auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _locationController = TextEditingController();
  final _specialtyController = TextEditingController();

  String _selectedLanguage = 'hi';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).register(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
            preferredLanguage: _selectedLanguage,
            location: _locationController.text.trim(),
            craftSpecialty: _specialtyController.text.trim(),
          );
      if (success && mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Artisan Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join ShilpSetu AI 🌿',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Empower your handmade craft with AI tools & direct digital reach',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (authState.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      authState.error!,
                      style:
                          const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                CustomTextField(
                  label: 'Full Name / पूरा नाम *',
                  hint: 'e.g. Ramu Weaver',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      color: AppColors.primary),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter name'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Phone Number / फ़ोन नंबर *',
                  hint: 'e.g. 9876543210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.primary),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter phone'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Password / पासवर्ड *',
                  hint: 'Min 6 characters',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.primary),
                  validator: (val) =>
                      val == null || val.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preferred Language / पसंदीदा भाषा',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLanguage,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.translate_rounded,
                            color: AppColors.primary, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide:
                              const BorderSide(color: AppColors.surfaceBorder),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'hi', child: Text('हिंदी (Hindi)')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(
                            value: 'bn', child: Text('বাংলা (Bengali)')),
                        DropdownMenuItem(
                            value: 'ta', child: Text('தமிழ் (Tamil)')),
                        DropdownMenuItem(
                            value: 'te', child: Text('తెలుగు (Telugu)')),
                        DropdownMenuItem(
                            value: 'mr', child: Text('मराठी (Marathi)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedLanguage = val);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Location / शहर या शिल्प क्षेत्र',
                  hint: 'e.g. Varanasi, Uttar Pradesh',
                  controller: _locationController,
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Craft Specialty / शिल्प का प्रकार',
                  hint: 'e.g. Handloom Weaving, Terracotta',
                  controller: _specialtyController,
                  prefixIcon: const Icon(Icons.brush_outlined,
                      color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.xl),
                CustomButton(
                  text: 'Register / खाता बनाएं',
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
