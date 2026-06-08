import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../providers/gym_provider.dart'; // ← add this

class CreateGymScreen extends ConsumerStatefulWidget {
  const CreateGymScreen({super.key});

  @override
  ConsumerState<CreateGymScreen> createState() => _CreateGymScreenState();
}

class _CreateGymScreenState extends ConsumerState<CreateGymScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _descCtrl   = TextEditingController();
  bool  _isLoading  = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _createGym() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioProvider);
      await dio.post(ApiEndpoints.createGym, data: {
        'name':        _nameCtrl.text.trim(),
        'address':     _addressCtrl.text.trim(),
        'city':        _cityCtrl.text.trim(),
        'phone':       _phoneCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
      });

      // ← Refresh gym provider so dashboard updates
      ref.invalidate(myGymProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Gym created successfully!'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/gym-owner');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create gym: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('Create Your Gym',
          style: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.2)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.fitness_center,
                      color: AppColors.accentGreen, size: 28),
                    SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Set up your gym profile',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('Members will see this when browsing gyms.',
                          style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                      ],
                    )),
                  ]),
                ),
                const SizedBox(height: 24),

                // ── Gym Name ─────────────────────────────────
                _buildLabel('Gym Name *'),
                _buildField(
                  controller: _nameCtrl,
                  hint:       'e.g. PowerFit Gym',
                  validator:  (v) => v == null || v.isEmpty
                      ? 'Gym name is required' : null,
                ),
                const SizedBox(height: 16),

                // ── City ─────────────────────────────────────
                _buildLabel('City *'),
                _buildField(
                  controller: _cityCtrl,
                  hint:       'e.g. Pune',
                  validator:  (v) => v == null || v.isEmpty
                      ? 'City is required' : null,
                ),
                const SizedBox(height: 16),

                // ── Address ───────────────────────────────────
                _buildLabel('Address'),
                _buildField(
                  controller: _addressCtrl,
                  hint:       'e.g. Shop 12, Wakad Road',
                ),
                const SizedBox(height: 16),

                // ── Phone ─────────────────────────────────────
                _buildLabel('Phone'),
                _buildField(
                  controller: _phoneCtrl,
                  hint:       'e.g. 9876543210',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // ── Description ───────────────────────────────
                _buildLabel('Description'),
                TextFormField(
                  controller: _descCtrl,
                  maxLines:   3,
                  style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText:  'Tell members about your gym...',
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                    filled:    true,
                    fillColor: AppColors.bgCard,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.accentGreen, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Submit ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createGym,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: AppColors.bgPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.bgPrimary))
                        : const Text('Create Gym 🏋️',
                            style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
      style: const TextStyle(
        color: AppColors.textMuted, fontSize: 12)),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) => TextFormField(
    controller:   controller,
    keyboardType: keyboardType,
    validator:    validator,
    style: const TextStyle(
      color: AppColors.textPrimary, fontSize: 14),
    decoration: InputDecoration(
      hintText:  hint,
      hintStyle: const TextStyle(
        color: AppColors.textMuted, fontSize: 13),
      filled:    true,
      fillColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.accentGreen, width: 1.5)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error)),
    ),
  );
}