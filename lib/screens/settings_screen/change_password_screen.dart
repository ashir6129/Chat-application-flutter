import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isSaving = false;

  bool get _isDirty =>
      _currentCtrl.text.isNotEmpty ||
          _newCtrl.text.isNotEmpty ||
          _confirmCtrl.text.isNotEmpty;

  // Password strength
  int _strength(String p) {
    int s = 0;
    if (p.length >= 8) s++;
    if (p.contains(RegExp(r'[A-Z]'))) s++;
    if (p.contains(RegExp(r'[0-9]'))) s++;
    if (p.contains(RegExp(r'[!@#\$&*~%^()]'))) s++;
    return s;
  }

  Color _strengthColor(int s) {
    if (s <= 1) return const Color(0xFFE24B4A);
    if (s == 2) return const Color(0xFFE87D2B);
    if (s == 3) return const Color(0xFFE8C22B);
    return const Color(0xFF3B6D11);
  }

  String _strengthLabel(int s) {
    if (s <= 1) return 'Weak';
    if (s == 2) return 'Fair';
    if (s == 3) return 'Good';
    return 'Strong';
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your changes will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard',
                style: TextStyle(color: Color(0xFFE24B4A))),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1)); // replace with API call
    setState(() => _isSaving = false);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password updated successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _strength(_newCtrl.text);
    final hasNewText = _newCtrl.text.isNotEmpty;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground(context),
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: AppColors.primaryText(context)),
            onPressed: () async {
              if (await _onWillPop()) Navigator.pop(context);
            },
          ),
          title: Text(
            'Change Password',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
          actions: [
            _isSaving
                ? const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
                : TextButton(
              onPressed: _save,
              child: Text(
                'Save',
                style: TextStyle(
                  color: AppColors.buttonColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),

              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.borderLine(context), width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.shield_tick,
                        size: 18, color: AppColors.buttonColor(context)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Choose a strong password you haven\'t used before.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryText(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _SectionHeader(label: 'Current Password'),
              const SizedBox(height: 8),
              _PasswordField(
                controller: _currentCtrl,
                hint: 'Enter current password',
                show: _showCurrent,
                onToggle: () => setState(() => _showCurrent = !_showCurrent),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Required' : null,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.buttonColor(context),
                    ),
                  ),
                ),
              ),

              _SectionHeader(label: 'New Password'),
              const SizedBox(height: 8),
              _PasswordField(
                controller: _newCtrl,
                hint: 'Enter new password',
                show: _showNew,
                onToggle: () => setState(() => _showNew = !_showNew),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 8) return 'At least 8 characters';
                  if (v == _currentCtrl.text)
                    return 'Must differ from current password';
                  return null;
                },
              ),

              // Strength bar
              if (hasNewText) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    ...List.generate(4, (i) {
                      final active = i < s;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                          decoration: BoxDecoration(
                            color: active
                                ? _strengthColor(s)
                                : AppColors.borderLine(context),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 10),
                    Text(
                      _strengthLabel(s),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _strengthColor(s),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _PasswordHints(password: _newCtrl.text),
              ],

              const SizedBox(height: 16),

              _SectionHeader(label: 'Confirm New Password'),
              const SizedBox(height: 8),
              _PasswordField(
                controller: _confirmCtrl,
                hint: 'Re-enter new password',
                show: _showConfirm,
                onToggle: () =>
                    setState(() => _showConfirm = !_showConfirm),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v != _newCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text(
                    'Update Password',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Password hints checklist
// ─────────────────────────────────────────────────────────────────────────────
class _PasswordHints extends StatelessWidget {
  final String password;
  const _PasswordHints({required this.password});

  @override
  Widget build(BuildContext context) {
    final checks = [
      ('At least 8 characters', password.length >= 8),
      ('One uppercase letter', password.contains(RegExp(r'[A-Z]'))),
      ('One number', password.contains(RegExp(r'[0-9]'))),
      ('One special character', password.contains(RegExp(r'[!@#\$&*~%^()]'))),
    ];

    return Column(
      children: checks.map((c) {
        final ok = c.$2;
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                ok ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 14,
                color: ok
                    ? const Color(0xFF3B6D11)
                    : AppColors.mutedText(context),
              ),
              const SizedBox(width: 6),
              Text(
                c.$1,
                style: TextStyle(
                  fontSize: 12,
                  color: ok
                      ? AppColors.primaryText(context)
                      : AppColors.secondaryText(context),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable password field
// ─────────────────────────────────────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool show;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.show,
    required this.onToggle,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !show,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(fontSize: 14, color: AppColors.primaryText(context)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.secondaryText(context)),
        filled: true,
        fillColor: AppColors.secondaryBackground(context),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFE24B4A), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFE24B4A), width: 1),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            show ? Iconsax.eye : Iconsax.eye_slash,
            size: 18,
            color: AppColors.secondaryText(context),
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.secondaryText(context),
        letterSpacing: 0.2,
      ),
    );
  }
}