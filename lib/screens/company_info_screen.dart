import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/supabase_service.dart';

class CompanyInfoScreen extends StatefulWidget {
  final VoidCallback? onSaveContinue;

  const CompanyInfoScreen({super.key, this.onSaveContinue});

  @override
  State<CompanyInfoScreen> createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _companyDescriptionController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCompanyInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final supabase = SupabaseService.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('users').update({
        'company_name': _companyNameController.text.trim(),
        'company_description': _companyDescriptionController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      debugPrint('[CompanyInfo] Company info saved successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company information saved'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSaveContinue?.call();
      }
    } catch (e) {
      debugPrint('[CompanyInfo] Error saving company info: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving company info: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'COMPANY INFORMATION',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _companyNameController,
                        decoration: InputDecoration(
                          labelText: 'Company Name',
                          hintText: 'Enter your company name',
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                        ),
                        style: const TextStyle(color: AppColors.textPrimary),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your company name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _companyDescriptionController,
                        decoration: InputDecoration(
                          labelText: 'Company Description',
                          hintText: 'Describe your company and services',
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                        ),
                        style: const TextStyle(color: AppColors.textPrimary),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your company description';
                          }
                          if (value.trim().length < 10) {
                            return 'Description should be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveCompanyInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Save & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
