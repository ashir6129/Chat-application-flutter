import 'package:flutter/material.dart';
import '../../api_services/auth_service.dart';
import '../../core/app_colors.dart';
import 'signup_otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure = true;
  bool _obscureC = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Inline Dialog Helpers ──────────────────────────────────────────────────

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade400),
            const SizedBox(width: 8),
            const Text("Error", style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ── Register ────────────────────────────────────────────────────────

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    if (password != confirm) {
      _showError("Passwords do not match");
      return;
    }

    setState(() => _loading = true);

    try {
      final data = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );

      final resetToken = AuthService.readResetToken(data);
      if (resetToken == null) {
        if (!mounted) return;
        _showError('Could not start verification. Please try again.');
        return;
      }

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SignupOtpScreen(
            email: email,
            resetToken: resetToken,
            mockOtp: AuthService.readMockOtp(data),
            resendAfterSeconds: AuthService.readResendSeconds(data),
          ),
        ),
      );
    } catch (e) {
      if (mounted) _showError(AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Inline Input Field ─────────────────────────────────────────────────────

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.mutedText(context),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppColors.mutedText(context),
              size: 20,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.secondaryText(context).withOpacity(0.07),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryText(context).withOpacity(0.3),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Inline Button ──────────────────────────────────────────────────────────

  Widget _button({
    required String label,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryText(context),
          disabledBackgroundColor:
          AppColors.primaryText(context).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: loading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.secondaryText(context),
          ),
        )
            : Text(
          label,
          style: TextStyle(
            color: Theme.of(context).scaffoldBackgroundColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create account ✨",
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Join and connect with people nearby",
          style: TextStyle(
            color: AppColors.secondaryText(context),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 28),

        _inputField(
          controller: _nameCtrl,
          label: "Full Name",
          hint: "Enter your full name",
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 14),

        _inputField(
          controller: _emailCtrl,
          label: "Email",
          hint: "you@example.com",
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),

        _inputField(
          controller: _passCtrl,
          label: "Password",
          hint: "Min 8 characters",
          prefixIcon: Icons.lock_outline_rounded,
          obscure: _obscure,
          suffixIcon: IconButton(
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.mutedText(context),
              size: 20,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: 14),

        _inputField(
          controller: _confirmCtrl,
          label: "Confirm Password",
          hint: "Re-enter password",
          prefixIcon: Icons.lock_outline_rounded,
          obscure: _obscureC,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureC
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.mutedText(context),
              size: 20,
            ),
            onPressed: () => setState(() => _obscureC = !_obscureC),
          ),
        ),
        const SizedBox(height: 28),

        _button(
          label: "Create Account",
          loading: _loading,
          onTap: _register,
        ),
      ],
    );
  }
}