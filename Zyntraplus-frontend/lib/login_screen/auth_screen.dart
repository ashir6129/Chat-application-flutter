import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../core/app_colors.dart';
import '../../core/social_auth_service.dart';
import '../screens/main_screen/main_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _tabCtrl = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  bool get _isLogin => _tabCtrl.index == 0;
  bool _socialLoading = false;

  Future<void> _socialSignIn(Future<void> Function() action) async {
    if (_socialLoading) return;
    setState(() => _socialLoading = true);
    try {
      await action();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showError(SocialAuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _socialLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: size.width * 0.2,
            right: size.width * 0.2,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.buttonColor(context).withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Lottie.asset(
                          'assets/lottie/cat_animation.json',
                          width: 240,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 100),
                        Text(
                          'Chat with people near you',
                          style: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBackground(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      controller: _tabCtrl,
                      indicator: BoxDecoration(
                        color: AppColors.buttonColor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.secondaryText(context),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: "Sign In"),
                        Tab(text: "Sign Up"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _isLogin
                        ? const LoginScreen(key: ValueKey('login'))
                        : const SignupScreen(key: ValueKey('signup')),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.borderLine(context),
                          thickness: 0.8,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            color: AppColors.mutedText(context),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.borderLine(context),
                          thickness: 0.8,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: 'Google',
                          icon: Icons.g_mobiledata_rounded,
                          loading: _socialLoading,
                          onTap: () => _socialSignIn(SocialAuthService.signInWithGoogle),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialButton(
                          label: 'Apple',
                          icon: Icons.apple,
                          loading: _socialLoading,
                          onTap: () => _socialSignIn(SocialAuthService.signInWithApple),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "By continuing you agree to our ",
                        style: TextStyle(
                          color: AppColors.mutedText(context),
                          fontSize: 11,
                        ),
                        children: [
                          TextSpan(
                            text: "Terms",
                            style: TextStyle(
                              color: AppColors.buttonColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: "  &  "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                              color: AppColors.buttonColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool loading;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderLine(context),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.secondaryText(context),
                ),
              )
            else
              Icon(
                icon,
                color: AppColors.secondaryText(context),
                size: 22,
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}