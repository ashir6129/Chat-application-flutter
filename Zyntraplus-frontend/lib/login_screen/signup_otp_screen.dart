import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_services/auth_service.dart';
import '../core/app_colors.dart';
import '../screens/main_screen/main_screen.dart';

class SignupOtpScreen extends StatefulWidget {
  final String email;
  final String resetToken;
  final String? mockOtp;
  final int resendAfterSeconds;

  const SignupOtpScreen({
    super.key,
    required this.email,
    required this.resetToken,
    this.mockOtp,
    this.resendAfterSeconds = 60,
  });

  @override
  State<SignupOtpScreen> createState() => _SignupOtpScreenState();
}

class _SignupOtpScreenState extends State<SignupOtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  String? _resetToken;
  String? _mockOtp;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _resetToken = widget.resetToken;
    _mockOtp = widget.mockOtp;
    _startResendTimer(widget.resendAfterSeconds);
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer(int seconds) {
    _resendTimer?.cancel();
    if (seconds <= 0) return;
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _resend() async {
    if (_resetToken == null || _resendSeconds > 0 || _loading) return;

    setState(() => _loading = true);
    try {
      final data = await AuthService.resendOtp(
        email: widget.email,
        resetToken: _resetToken!,
      );
      if (!mounted) return;
      setState(() {
        _resetToken = AuthService.readResetToken(data) ?? _resetToken;
        _mockOtp = AuthService.readMockOtp(data);
      });
      _startResendTimer(AuthService.readResendSeconds(data));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']?.toString() ?? 'OTP resent'),
          backgroundColor: AppColors.buttonColor(context),
        ),
      );
    } catch (e) {
      _showError(AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    final otp = _otpCtrl.text.trim();
    if (_resetToken == null) {
      _showError('Verification session expired. Please sign up again.');
      return;
    }
    if (otp.length < 6) {
      _showError('Enter the 6-digit OTP');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.verifyRegistration(
        email: widget.email,
        otp: otp,
        resetToken: _resetToken!,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) _showError(AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
            Text(
              'Verify email',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to\n${widget.email}',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (_mockOtp != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.buttonColor(context).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.buttonColor(context).withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Dev OTP: $_mockOtp',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 22,
                letterSpacing: 8,
                fontWeight: FontWeight.w700,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                hintText: '••••••',
                filled: true,
                fillColor: AppColors.secondaryText(context).withValues(alpha: 0.07),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryText(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondaryText(context),
                        ),
                      )
                    : Text(
                        'Verify & Continue',
                        style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: (_loading || _resendSeconds > 0) ? null : _resend,
                child: Text(
                  _resendSeconds > 0 ? 'Resend OTP in ${_resendSeconds}s' : 'Resend OTP',
                  style: TextStyle(
                    color: _resendSeconds > 0
                        ? AppColors.mutedText(context)
                        : AppColors.buttonColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
