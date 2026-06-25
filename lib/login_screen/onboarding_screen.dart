import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';


class _OnboardingData {
  final String title;
  final String titleAccent;
  final String subtitle;
  final List<String> imageUrls;
  final IconData decorIconLeft;
  final IconData decorIconRight;

  const _OnboardingData({
    required this.title,
    required this.titleAccent,
    required this.subtitle,
    required this.imageUrls,
    required this.decorIconLeft,
    required this.decorIconRight,
  });
}

const _pages = [
  _OnboardingData(
    title: 'Your Premier\nSocial ',
    titleAccent: 'Connection',
    subtitle: 'A smarter, faster way to share life\nwith your circle.',
    imageUrls: [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400',
      'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400',
    ],
    decorIconLeft: Iconsax.heart5,
    decorIconRight: Iconsax.star1,
  ),
  _OnboardingData(
    title: 'Discover &\nFollow ',
    titleAccent: 'Creators',
    subtitle: 'Find artists, fashionistas & influencers\nthat inspire you.',
    imageUrls: [
      'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    ],
    decorIconLeft: Iconsax.profile_2user,
    decorIconRight: Iconsax.video_play,
  ),
  _OnboardingData(
    title: 'Go Live &\nGo ',
    titleAccent: 'Viral',
    subtitle: 'Stream to thousands and build\nyour audience in real-time.',
    imageUrls: [
      'https://images.unsplash.com/photo-1516321497487-e288fb19713f?w=400',
      'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=400',
      'https://images.unsplash.com/photo-1520466809213-7b9a56adcd45?w=400',
    ],
    decorIconLeft: Iconsax.flash_1,
    decorIconRight: Iconsax.video,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatCtrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _float = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      // TODO: navigate to main app
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground(context),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryBackground(context),
                AppColors.secondaryBackground(context),
                AppColors.primaryBackground(context),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── PageView for card clusters ───────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _CardCluster(
                        data: _pages[index],
                        floatAnim: _float,
                        size: size,
                      );
                    },
                  ),
                ),

                // ── Bottom section ───────────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _BottomSection(
                    key: ValueKey(_currentPage),
                    data: _pages[_currentPage],
                    currentPage: _currentPage,
                    totalPages: _pages.length,
                    onContinue: _next,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card Cluster
// ─────────────────────────────────────────────────────────────────────────────

class _CardCluster extends StatelessWidget {
  final _OnboardingData data;
  final Animation<double> floatAnim;
  final Size size;

  const _CardCluster({
    required this.data,
    required this.floatAnim,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Card 1 – back left
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, __) => Transform.translate(
              offset: Offset(-floatAnim.value * 0.8, floatAnim.value),
              child: Transform.rotate(
                angle: -0.28,
                child: _PhotoCard(
                  width: size.width * 0.55,
                  height: size.height * 0.30,
                  offset: Offset(-size.width * 0.12, -size.height * 0.02),
                  imageUrl: data.imageUrls[0],
                  borderColor: AppColors.borderLine(context),
                  bgColor: AppColors.secondaryBackground(context),
                  iconColor: AppColors.buttonColor(context),
                ),
              ),
            ),
          ),

          // Card 2 – back right
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, __) => Transform.translate(
              offset: Offset(floatAnim.value, -floatAnim.value * 0.6),
              child: Transform.rotate(
                angle: 0.22,
                child: _PhotoCard(
                  width: size.width * 0.50,
                  height: size.height * 0.27,
                  offset:
                  Offset(size.width * 0.10, -size.height * 0.04),
                  imageUrl: data.imageUrls[1],
                  borderColor: AppColors.borderLine(context),
                  bgColor: AppColors.secondaryBackground(context),
                  iconColor: AppColors.buttonColor(context),
                ),
              ),
            ),
          ),

          // Card 3 – front center
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, __) => Transform.translate(
              offset: Offset(
                  floatAnim.value * 0.3, floatAnim.value * 0.5),
              child: Transform.rotate(
                angle: 0.08,
                child: _PhotoCard(
                  width: size.width * 0.62,
                  height: size.height * 0.34,
                  offset: Offset(
                      size.width * 0.03, size.height * 0.04),
                  imageUrl: data.imageUrls[2],
                  hasShadowGlow: true,
                  glowColor: AppColors.buttonColor(context),
                  borderColor: AppColors.buttonColor(context),
                  bgColor: AppColors.secondaryBackground(context),
                  iconColor: AppColors.buttonColor(context),
                ),
              ),
            ),
          ),

          // Decor icon – top left
          Positioned(
            left: size.width * 0.05,
            top: size.height * 0.03,
            child: AnimatedBuilder(
              animation: floatAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, -floatAnim.value * 1.2),
                child: _DecorIcon(
                  icon: data.decorIconLeft,
                  color: AppColors.heartColor(context),
                  size: 32,
                ),
              ),
            ),
          ),

          // Decor icon – bottom right
          Positioned(
            right: size.width * 0.07,
            bottom: size.height * 0.05,
            child: AnimatedBuilder(
              animation: floatAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(floatAnim.value * 0.5, -floatAnim.value),
                child: _DecorIcon(
                  icon: data.decorIconRight,
                  color: AppColors.buttonColor(context),
                  size: 28,
                ),
              ),
            ),
          ),

          // Curved arrow – right side
          Positioned(
            right: size.width * 0.06,
            bottom: size.height * 0.12,
            child: _CurvedArrow(
              color: AppColors.verifiedBadge(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom section (animated switch between pages)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  final _OnboardingData data;
  final int currentPage;
  final int totalPages;
  final VoidCallback onContinue;

  const _BottomSection({
    super.key,
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Headline
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: data.title,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.8,
                  ),
                ),
                TextSpan(
                  text: data.titleAccent,
                  style: TextStyle(
                    color: AppColors.buttonColor(context),
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    height: 1.15,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Text(
            data.subtitle,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 14,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 32),

          // Dots + Continue button
          Row(
            children: [
              // ── Dot indicators ─────────────────────────────────────
              Row(
                children: List.generate(totalPages, (i) {
                  final isActive = i == currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(right: 6),
                    width: isActive ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.buttonColor(context)
                          : AppColors.mutedText(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const Spacer(),

              // ── Continue / Get Started button ───────────────────────
              _ContinueButton(
                label: currentPage == totalPages - 1
                    ? "Let's Go"
                    : 'Continue',
                onTap: onContinue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo Card
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoCard extends StatelessWidget {
  final double width;
  final double height;
  final Offset offset;
  final String imageUrl;
  final bool hasShadowGlow;
  final Color glowColor;
  final Color borderColor;
  final Color bgColor;
  final Color iconColor;

  const _PhotoCard({
    required this.width,
    required this.height,
    required this.offset,
    required this.imageUrl,
    required this.borderColor,
    required this.bgColor,
    required this.iconColor,
    this.hasShadowGlow = false,
    this.glowColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            if (hasShadowGlow)
              BoxShadow(
                color: glowColor.withOpacity(0.25),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: bgColor,
              child: Icon(Iconsax.image, color: iconColor, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Decor Icon (replaces emojis)
// ─────────────────────────────────────────────────────────────────────────────

class _DecorIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _DecorIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Curved Arrow
// ─────────────────────────────────────────────────────────────────────────────

class _CurvedArrow extends StatelessWidget {
  final Color color;
  const _CurvedArrow({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 50),
      painter: _ArrowPainter(color: color),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  _ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.8, 0)
      ..cubicTo(
        size.width * 1.2, size.height * 0.3,
        size.width * 0.0, size.height * 0.6,
        size.width * 0.3, size.height,
      );
    canvas.drawPath(path, paint);

    canvas.drawLine(Offset(size.width * 0.3, size.height),
        Offset(size.width * 0.05, size.height * 0.82), paint);
    canvas.drawLine(Offset(size.width * 0.3, size.height),
        Offset(size.width * 0.55, size.height * 0.80), paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Continue Button
// ─────────────────────────────────────────────────────────────────────────────

class _ContinueButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _ContinueButton({required this.label, required this.onTap});

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.93,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pressCtrl,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.reverse(),
        onTapUp: (_) {
          _pressCtrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.forward(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.buttonColor(context),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonColor(context).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: AppColors.buttonTextColor(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Iconsax.arrow_right_1,
                size: 16,
                color: AppColors.buttonTextColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}