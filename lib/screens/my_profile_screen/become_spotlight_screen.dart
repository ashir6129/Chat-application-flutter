import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Premium Spotlight subscription landing — matches profile tab palette.
class BecomeSpotlightScreen extends StatefulWidget {
  const BecomeSpotlightScreen({super.key});

  static const bg = Color(0xFF121B22);
  static const card = Color(0xFF1A2332);
  static const cardBorder = Color(0xFF2A3942);
  static const accent = Color(0xFF00A884);
  static const muted = Color(0xFF8696A0);
  static const gold = Color(0xFFFFD700);

  @override
  State<BecomeSpotlightScreen> createState() => _BecomeSpotlightScreenState();
}

class _BecomeSpotlightScreenState extends State<BecomeSpotlightScreen> {
  int _selectedPlan = 1;

  static const _plans = [
    _Plan(
      id: 0,
      label: 'Weekly',
      tagline: 'Stay visible',
      price: '₦1,500',
      period: '/week',
      billing: 'Billed weekly',
      saveLabel: null,
      popular: false,
    ),
    _Plan(
      id: 1,
      label: 'Monthly',
      tagline: 'Most flexible',
      price: '₦4,500',
      period: '/month',
      billing: 'Billed monthly',
      saveLabel: 'Save 20%',
      popular: true,
    ),
    _Plan(
      id: 2,
      label: 'Yearly',
      tagline: 'Best value',
      price: '₦32,000',
      period: '/year',
      billing: 'Billed yearly',
      saveLabel: 'Save 40%',
      popular: false,
    ),
  ];

  static const _features = [
    _SpotlightFeature(Iconsax.eye, 'More Visibility', 'Show up more in nearby & map'),
    _SpotlightFeature(Iconsax.message, 'More Chats', 'Get more messages'),
    _SpotlightFeature(Iconsax.crown, 'Premium Badge', 'Stand out with badge'),
    _SpotlightFeature(Iconsax.gift, 'Exclusive Perks', 'Special rewards'),
  ];

  static const _benefits = [
    _Benefit('Spotlight Badge', 'Exclusive badge'),
    _Benefit('See who viewed your profile', "Know who's interested in you"),
    _Benefit('Priority in Explore Map', 'Show up first on the map'),
    _Benefit('Ad-free experience', 'No ads, just connections'),
    _Benefit('Top placement in Nearby', 'More visibility, more profile views'),
    _Benefit('Unlimited likes & waves', 'Connect without limits'),
    _Benefit('Premium profile themes', 'Unlock stylish profile looks'),
    _Benefit('Cancel anytime', "You're in control"),
  ];

  static const _testimonials = [
    _Testimonial('Jessica', 'https://i.pravatar.cc/150?img=47', 'I get way more views and chats now!'),
    _Testimonial('Aron', 'https://i.pravatar.cc/150?img=33', 'Spotlight helped me grow my audience fast.'),
    _Testimonial('Sarah', 'https://i.pravatar.cc/150?img=32', 'Best investment for my creator profile.'),
    _Testimonial('Michael', 'https://i.pravatar.cc/150?img=12', 'More visibility, more real connections.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BecomeSpotlightScreen.bg,
      appBar: AppBar(
        backgroundColor: BecomeSpotlightScreen.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Become Spotlight',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            const SizedBox(height: 22),
            _buildFeaturesRow(),
            const SizedBox(height: 26),
            _buildPlanHeader(),
            const SizedBox(height: 14),
            _buildPlanCards(),
            const SizedBox(height: 22),
            _buildBenefitsCard(),
            const SizedBox(height: 24),
            _buildPaymentButton(),
            const SizedBox(height: 10),
            _buildSecureNote(),
            const SizedBox(height: 28),
            _buildTestimonials(),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                  children: [
                    TextSpan(text: 'Go '),
                    TextSpan(
                      text: 'Spotlight.',
                      style: TextStyle(color: BecomeSpotlightScreen.gold),
                    ),
                    TextSpan(text: ' Get Discovered.'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Stand out. Get noticed. More views. More chats. More you.',
                style: TextStyle(
                  color: BecomeSpotlightScreen.muted.withOpacity(0.95),
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 8,
                right: 4,
                child: Icon(Iconsax.star_1, size: 10, color: Colors.white.withOpacity(0.5)),
              ),
              Positioned(
                top: 0,
                left: 8,
                child: Icon(Icons.add, size: 12, color: Colors.white.withOpacity(0.45)),
              ),
              Positioned(
                bottom: 28,
                left: 0,
                child: Icon(Iconsax.star_1, size: 8, color: Colors.white.withOpacity(0.35)),
              ),
              Positioned(
                top: 18,
                left: 24,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        BecomeSpotlightScreen.gold.withOpacity(0.25),
                        BecomeSpotlightScreen.accent.withOpacity(0.15),
                      ],
                    ),
                  ),
                  child: const Icon(Iconsax.crown_1, color: BecomeSpotlightScreen.gold, size: 30),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B6914).withOpacity(0.35),
                    shape: BoxShape.circle,
                    border: Border.all(color: BecomeSpotlightScreen.gold.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.payments_outlined, color: BecomeSpotlightScreen.gold, size: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: BecomeSpotlightScreen.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BecomeSpotlightScreen.cardBorder.withOpacity(0.55), width: 0.6),
      ),
      child: Row(
        children: _features.map((f) => Expanded(child: _featureItem(f))).toList(),
      ),
    );
  }

  Widget _featureItem(_SpotlightFeature f) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: BecomeSpotlightScreen.accent.withOpacity(0.55), width: 1.2),
          ),
          child: Icon(f.icon, color: BecomeSpotlightScreen.accent, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          f.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          f.subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: BecomeSpotlightScreen.muted,
            fontSize: 8.5,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Choose Your Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Icon(Iconsax.star_1, color: BecomeSpotlightScreen.gold, size: 12),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '7-Day Money Back Guarantee',
            style: TextStyle(
              color: BecomeSpotlightScreen.gold.withOpacity(0.95),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCards() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _plans.map((plan) {
        final selected = _selectedPlan == plan.id;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlan = plan.id),
            child: Container(
              margin: EdgeInsets.only(
                left: plan.id == 0 ? 0 : 5,
                right: plan.id == 2 ? 0 : 5,
              ),
              padding: EdgeInsets.fromLTRB(8, plan.popular ? 18 : 14, 8, 12),
              decoration: BoxDecoration(
                color: BecomeSpotlightScreen.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? BecomeSpotlightScreen.accent
                      : BecomeSpotlightScreen.cardBorder.withOpacity(0.7),
                  width: selected ? 1.8 : 0.8,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (plan.popular)
                    Positioned(
                      top: -28,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: BecomeSpotlightScreen.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'MOST POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Column(
                    children: [
                      Text(
                        plan.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        plan.tagline,
                        style: const TextStyle(
                          color: BecomeSpotlightScreen.accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (plan.saveLabel != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: BecomeSpotlightScreen.accent.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            plan.saveLabel!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ] else
                        const SizedBox(height: 22),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                          children: [
                            TextSpan(text: plan.price),
                            TextSpan(
                              text: plan.period,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: BecomeSpotlightScreen.muted.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.billing,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: BecomeSpotlightScreen.muted,
                          fontSize: 8.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? BecomeSpotlightScreen.accent : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? BecomeSpotlightScreen.accent
                                : BecomeSpotlightScreen.muted.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white, size: 12)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BecomeSpotlightScreen.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BecomeSpotlightScreen.cardBorder.withOpacity(0.55), width: 0.6),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _benefits.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _benefitItem(_benefits[i])),
                const SizedBox(width: 12),
                Expanded(child: _benefitItem(_benefits[i + 1])),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _benefitItem(_Benefit b) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 1),
          decoration: const BoxDecoration(
            color: BecomeSpotlightScreen.accent,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                b.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                b.subtitle,
                style: const TextStyle(
                  color: BecomeSpotlightScreen.muted,
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Proceeding with ${_plans[_selectedPlan].label} plan…'),
            backgroundColor: BecomeSpotlightScreen.accent,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00E68A), Color(0xFF00FF85)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: BecomeSpotlightScreen.accent.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue to Payment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSecureNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Iconsax.lock, color: BecomeSpotlightScreen.muted.withOpacity(0.8), size: 13),
        const SizedBox(width: 6),
        Text(
          'Secure payment',
          style: TextStyle(
            color: BecomeSpotlightScreen.muted.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Iconsax.star_1, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            const Text(
              'Loved by Spotlight Creators',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Join thousands of happy creators already shining',
          style: TextStyle(
            color: BecomeSpotlightScreen.muted.withOpacity(0.95),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _testimonials.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _testimonialCard(_testimonials[i]),
          ),
        ),
      ],
    );
  }

  Widget _testimonialCard(_Testimonial t) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BecomeSpotlightScreen.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BecomeSpotlightScreen.cardBorder.withOpacity(0.5), width: 0.6),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(t.avatar),
          ),
          const SizedBox(height: 8),
          Text(
            t.quote,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              height: 1.35,
            ),
          ),
          const Spacer(),
          Text(
            '- ${t.name}',
            style: const TextStyle(
              color: BecomeSpotlightScreen.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: BecomeSpotlightScreen.muted.withOpacity(0.95),
            fontSize: 11,
            height: 1.5,
          ),
          children: const [
            TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(color: BecomeSpotlightScreen.accent),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(color: BecomeSpotlightScreen.accent),
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}

class _Plan {
  final int id;
  final String label;
  final String tagline;
  final String price;
  final String period;
  final String billing;
  final String? saveLabel;
  final bool popular;

  const _Plan({
    required this.id,
    required this.label,
    required this.tagline,
    required this.price,
    required this.period,
    required this.billing,
    this.saveLabel,
    required this.popular,
  });
}

class _SpotlightFeature {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SpotlightFeature(this.icon, this.title, this.subtitle);
}

class _Benefit {
  final String title;
  final String subtitle;

  const _Benefit(this.title, this.subtitle);
}

class _Testimonial {
  final String name;
  final String avatar;
  final String quote;

  const _Testimonial(this.name, this.avatar, this.quote);
}
