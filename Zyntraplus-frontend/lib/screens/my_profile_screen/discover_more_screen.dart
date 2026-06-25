import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/main_tab_navigation.dart';
import '../monetization_screen/monetization_dashboard.dart';
import 'become_spotlight_screen.dart';

/// Extended discovery hub from the Profile tab.
class DiscoverMoreScreen extends StatelessWidget {
  const DiscoverMoreScreen({super.key});

  static const _bg = Color(0xFF121B22);
  static const _card = Color(0xFF1A2332);
  static const _cardBorder = Color(0xFF2A3942);
  static const _accent = Color(0xFF00A884);
  static const _muted = Color(0xFF8696A0);
  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Discover more',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSpotlightPromo(context),
            const SizedBox(height: 22),
            _sectionHeader('PREMIUM & GROWTH'),
            const SizedBox(height: 12),
            _buildItem(
              context,
              icon: Iconsax.crown_1,
              color: _gold,
              title: 'Become Spotlight',
              subtitle: 'Get discovered, more views & premium badge',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BecomeSpotlightScreen()),
              ),
            ),
            _buildItem(
              context,
              icon: Iconsax.chart_21,
              color: _accent,
              title: 'Creator Dashboard',
              subtitle: 'Analytics, earnings & professional tools',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonetizationScreen()),
              ),
            ),
            const SizedBox(height: 22),
            _sectionHeader('EXPLORE & CONNECT'),
            const SizedBox(height: 12),
            _buildItem(
              context,
              icon: Iconsax.location,
              color: const Color(0xFFFF6584),
              title: 'People Nearby',
              subtitle: 'Find and connect with people around you',
              onTap: () => _switchTab(context, 3),
            ),
            _buildItem(
              context,
              icon: Iconsax.document_text,
              color: _accent,
              title: 'Feeds',
              subtitle: 'Latest posts from your network',
              onTap: () => _switchTab(context, 0),
            ),
            _buildItem(
              context,
              icon: Iconsax.people,
              color: const Color(0xFF7C4DFF),
              title: 'Communities',
              subtitle: 'Find and join groups that match your interests',
              onTap: () {},
            ),
            _buildItem(
              context,
              icon: Iconsax.messages_3,
              color: const Color(0xFF3D9BFF),
              title: 'Groups',
              subtitle: 'Discover group chats and conversations',
              onTap: () {},
            ),
            const SizedBox(height: 22),
            _sectionHeader('TOOLS & MARKETPLACE'),
            const SizedBox(height: 12),
            _buildItem(
              context,
              icon: Iconsax.bag,
              color: const Color(0xFFFFB300),
              title: 'Marketplace',
              subtitle: 'Buy and sell products in your network',
              onTap: () => _switchTab(context, 2),
            ),
            _buildItem(
              context,
              icon: Iconsax.calendar,
              color: const Color(0xFF26C6DA),
              title: 'Events',
              subtitle: 'Upcoming events near you',
              onTap: () {},
            ),
            _buildItem(
              context,
              icon: Iconsax.gallery,
              color: const Color(0xFF9B59FF),
              title: 'Memories',
              subtitle: 'Relive your favourite moments',
              onTap: () {},
            ),
            _buildItem(
              context,
              icon: Iconsax.bookmark,
              color: const Color(0xFFFF5252),
              title: 'Saved',
              subtitle: 'Posts and content you saved for later',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotlightPromo(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BecomeSpotlightScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2A22), Color(0xFF122A24)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _accent.withOpacity(0.25), width: 0.8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(text: 'Go '),
                        TextSpan(
                          text: 'Spotlight',
                          style: TextStyle(color: _gold),
                        ),
                        TextSpan(text: ' — get discovered'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'More visibility, premium badge & exclusive perks.',
                    style: TextStyle(
                      color: _muted.withOpacity(0.95),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Learn more',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withOpacity(0.12),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Iconsax.crown_1, color: _gold, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  void _switchTab(BuildContext context, int index) {
    Navigator.pop(context);
    MainTabNavigation.goTo(index);
  }

  Widget _sectionHeader(String label) {
    return Text(
      label,
      style: TextStyle(
        color: _muted.withOpacity(0.85),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder.withOpacity(0.5), width: 0.6),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _muted.withOpacity(0.7), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
