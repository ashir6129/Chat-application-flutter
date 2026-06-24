import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyntraplus/login_screen/auth_screen.dart';
import 'package:zyntraplus/screens/main_screen/main_screen.dart';
import '../core/app_colors.dart';

// import 'package:your_app/screens/main_screen.dart';
// import 'package:your_app/screens/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _badgeController;
  late AnimationController _bottomNavController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _badgeFadeAnimation;
  late Animation<double> _badgeScaleAnimation;
  late Animation<double> _bottomNavFadeAnimation;
  late Animation<Offset> _bottomNavSlideAnimation;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
        );

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _badgeFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeOut),
    );
    _badgeScaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
    );

    _bottomNavController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bottomNavFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bottomNavController, curve: Curves.easeOut),
    );
    _bottomNavSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _bottomNavController, curve: Curves.easeOut),
        );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _fadeController.forward();
      _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _badgeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _bottomNavController.forward();
      _progressController.forward();
    });

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      _navigateBasedOnAuth();
    });
  }

  Future<void> _navigateBasedOnAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isLoggedIn
            ? const MainScreen() // replace with MainScreen()
            : const AuthScreen(), // replace with AuthScreen()
      ),
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _badgeController.dispose();
    _bottomNavController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Widget _buildChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.buttonColor(context).withOpacity(0.12)
            : AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isSelected
              ? AppColors.buttonColor(context).withOpacity(0.4)
              : AppColors.borderLine(context),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isSelected
                ? AppColors.buttonColor(context)
                : AppColors.secondaryText(context),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppColors.buttonColor(context)
                  : AppColors.secondaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: Stack(
        children: [
          // Soft radial glow behind the lottie
          Positioned(
            top: size.height * 0.12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.buttonColor(context).withOpacity(0.15),
                      AppColors.primaryBackground(context).withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              // --- Lottie animation ---
              SizedBox(
                height: size.height * 0.48,
                child: Center(
                  child: Lottie.asset(
                    'assets/lottie/splash_animation.json',
                    controller: _lottieController,
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                    onLoaded: (composition) {
                      _lottieController
                        ..duration = composition.duration
                        ..repeat();
                    },
                  ),
                ),
              ),

              // --- Logo + tagline ---
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // App name
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Near',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryText(context),
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Chat',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: AppColors.buttonColor(context),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tagline
                      Text(
                        'Chat with people near you',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryText(context),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Location badge ---
                      ScaleTransition(
                        scale: _badgeScaleAnimation,
                        child: FadeTransition(
                          opacity: _badgeFadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.buttonColor(context)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: AppColors.buttonColor(context)
                                    .withOpacity(0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 15,
                                  color: AppColors.buttonColor(context),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Location-based chat & feed',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.buttonColor(context),
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // --- Chips + progress + attribution ---
              FadeTransition(
                opacity: _bottomNavFadeAnimation,
                child: SlideTransition(
                  position: _bottomNavSlideAnimation,
                  child: Column(
                    children: [
                      // Chips row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildChip(
                              context: context,
                              icon: Icons.chat_bubble_outline_rounded,
                              label: 'Nearby Chat',
                              isSelected: true,
                            ),
                            const SizedBox(width: 8),
                            _buildChip(
                              context: context,
                              icon: Icons.grid_view_rounded,
                              label: 'Local Feed',
                            ),
                            const SizedBox(width: 8),
                            _buildChip(
                              context: context,
                              icon: Icons.near_me_rounded,
                              label: 'Discover',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Linear progress bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progressController.value,
                                minHeight: 3,
                                backgroundColor: AppColors.borderLine(context),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.buttonColor(context),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Attribution
                      Text(
                        'from EasyCodeSolutions',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.mutedText(context),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}