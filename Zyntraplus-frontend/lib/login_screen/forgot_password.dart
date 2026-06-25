import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../api_services/auth_service.dart';
import '../../core/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _otpSent = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  String? _resetToken;
  String? _mockOtp;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer(int seconds) {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = seconds);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendSeconds <= 1) {
        setState(() => _resendSeconds = 0);
        timer.cancel();
      } else {
        setState(() => _resendSeconds -= 1);
      }
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade400),
            const SizedBox(width: 8),
            const Text('Error', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccess(String title, String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade400),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 17)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOtp({bool isResend = false}) async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (isResend && (_resetToken == null || _resendSeconds > 0)) {
      return;
    }

    setState(() => _loading = true);

    try {
      final data = isResend
          ? await AuthService.resendOtp(email: email, resetToken: _resetToken!)
          : await AuthService.forgotPassword(email: email);

      final token = AuthService.readResetToken(data);
      if (token == null && !isResend) {
        await _showSuccess(
          'Check your email',
          data['message']?.toString() ??
              'If an account exists, an OTP has been sent.',
        );
        return;
      }

      setState(() {
        _otpSent = true;
        _resetToken = token ?? _resetToken;
        _mockOtp = AuthService.readMockOtp(data);
      });

      _startResendTimer(AuthService.readResendSeconds(data));

      if (!isResend) {
        await _showSuccess(
          'OTP Sent',
          data['message']?.toString() ?? 'Check your email for the OTP.',
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']?.toString() ?? 'OTP resent successfully'),
            backgroundColor: AppColors.buttonColor(context),
          ),
        );
        setState(() => _mockOtp = AuthService.readMockOtp(data));
      }
    } catch (e) {
      _showError(AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    final otp = _otpCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (_resetToken == null) {
      _showError('Request an OTP first');
      return;
    }

    if (otp.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showError('All fields are required');
      return;
    }

    if (pass.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (pass != confirm) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _loading = true);

    try {
      final data = await AuthService.resetPassword(
        email: email,
        otp: otp,
        resetToken: _resetToken!,
        newPassword: pass,
        confirmPassword: confirm,
      );

      await _showSuccess(
        'Success',
        data['message']?.toString() ?? 'Password reset successfully',
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _showError(AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          disabledBackgroundColor: AppColors.primaryText(context).withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  Widget _mockOtpBanner() {
    if (_mockOtp == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.buttonColor(context).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.buttonColor(context).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.buttonColor(context), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Dev mock OTP: $_mockOtp',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryText(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            Text(
              'Forgot Password',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _otpSent
                  ? 'Enter the OTP sent to your email and choose a new password'
                  : 'Enter your email and we will send you a one-time code',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            _inputField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            if (!_otpSent)
              _button(
                label: 'Send OTP',
                loading: _loading,
                onTap: () => _sendOtp(),
              ),
            if (_otpSent) ...[
              _mockOtpBanner(),
              _inputField(
                controller: _otpCtrl,
                label: 'OTP Code',
                hint: 'Enter 6-digit OTP',
                prefixIcon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
              const SizedBox(height: 16),
              _inputField(
                controller: _passCtrl,
                label: 'New Password',
                hint: 'At least 6 characters',
                prefixIcon: Icons.lock_outline_rounded,
                obscure: _obscurePass,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.mutedText(context),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              const SizedBox(height: 16),
              _inputField(
                controller: _confirmCtrl,
                label: 'Confirm Password',
                hint: 'Re-enter new password',
                prefixIcon: Icons.lock_rounded,
                obscure: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.mutedText(context),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 24),
              _button(
                label: 'Reset Password',
                loading: _loading,
                onTap: _resetPassword,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: (_loading || _resendSeconds > 0)
                      ? null
                      : () => _sendOtp(isResend: true),
                  child: Text(
                    _resendSeconds > 0
                        ? 'Resend OTP in ${_resendSeconds}s'
                        : 'Resend OTP',
                    style: TextStyle(
                      color: _resendSeconds > 0
                          ? AppColors.mutedText(context)
                          : AppColors.buttonColor(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
