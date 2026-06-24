import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';

class NearbyMapScreen extends StatelessWidget {
  const NearbyMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nearby Map',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFF1A2332)),
          ...List.generate(5, (i) {
            return Positioned(
              left: 40.0 + i * 55,
              top: 120.0 + (i % 3) * 80,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=${10 + i}',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor(context),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(i + 1) * 0.5} km',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
            );
          }),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.people, color: AppColors.buttonColor(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '12 people nearby',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpotlightUpgradeScreen extends StatelessWidget {
  const SpotlightUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upgrade to Spotlight',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Iconsax.star, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Get 10x More Visibility',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Appear at the top of Nearby for 24 hours',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _benefit(Iconsax.eye, 'Priority placement in Nearby'),
            _benefit(Iconsax.profile_2user, 'More profile views'),
            _benefit(Iconsax.message, 'Increased chat requests'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Spotlight activated!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA500),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Upgrade for \$4.99',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFA500)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}

class SpotlightCreatorsScreen extends StatelessWidget {
  final List<dynamic> users;

  const SpotlightCreatorsScreen({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Spotlight Creators',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final u = users[i];
          final name = u.name as String;
          final distance = u.distance as String;
          final avatar = u.avatarUrl as String;
          return ListTile(
            tileColor: AppColors.secondaryBackground(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: CircleAvatar(backgroundImage: NetworkImage(avatar)),
            title: Row(
              children: [
                Text(name,
                    style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Iconsax.verify, color: Colors.blue, size: 16),
              ],
            ),
            subtitle: Text(distance),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.buttonColor(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Chat',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}

void showNearbyGenderFilter(BuildContext context, String current,
    ValueChanged<String> onChanged) {
  final options = [
    {'title': 'All Gender', 'subtitle': 'Show everyone', 'icon': Iconsax.people, 'value': 'Everyone'},
    {'title': 'Male', 'subtitle': 'Show only male', 'icon': Icons.male, 'value': 'Male'},
    {'title': 'Female', 'subtitle': 'Show only female', 'icon': Icons.female, 'value': 'Female'},
    {'title': 'Non-binary', 'subtitle': 'Show non-binary', 'icon': Icons.transgender, 'value': 'Non-binary'},
    {'title': 'Prefer not to say', 'subtitle': 'Show users who prefer not to say', 'icon': Icons.visibility_off, 'value': 'Prefer not to say'},
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161C24),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mutedText(context).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Gender',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText(context),
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.borderLine(context), height: 1),
              const SizedBox(height: 8),
              ...options.map((opt) {
                final isSelected = current == opt['value'];
                return InkWell(
                  onTap: () {
                    onChanged(opt['value'] as String);
                    Navigator.pop(ctx);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFF232D36),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            opt['icon'] as IconData,
                            color: AppColors.secondaryText(context),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt['title'] as String,
                                style: TextStyle(
                                  color: AppColors.primaryText(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                opt['subtitle'] as String,
                                style: TextStyle(
                                  color: AppColors.secondaryText(context),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: AppColors.buttonColor(context),
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}
