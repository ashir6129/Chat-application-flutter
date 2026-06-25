import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';

/// Review page before sharing a reel (camera icon flow).
class NewReelReviewScreen extends StatefulWidget {
  const NewReelReviewScreen({super.key});

  @override
  State<NewReelReviewScreen> createState() => _NewReelReviewScreenState();
}

class _NewReelReviewScreenState extends State<NewReelReviewScreen> {
  final TextEditingController _caption = TextEditingController(
    text: 'My daily workout routine 💪 #fitness #workout #healthylifestyle',
  );

  String _playlist = 'Motivation Tips';
  String _products = 'Product tagged (2)';
  String _location = 'Lagos, Nigeria';
  String _audience = 'Everyone';

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

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
          'New Reel',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                            'https://picsum.photos/seed/reelcover/200/280',
                            width: 100,
                            height: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Iconsax.magic_star,
                                      color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'Edit Cover',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _caption,
                        maxLines: 6,
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Caption',
                          hintStyle:
                              TextStyle(color: AppColors.mutedText(context)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _optionRow('Add to Playlist', _playlist, Iconsax.video_play),
                _optionRow('Tag Products', _products, Iconsax.bag),
                _optionRow('Add Location', _location, Iconsax.location),
                _optionRow('Audience', _audience, Iconsax.people),
                _optionRow('More Options', '', Iconsax.more, showValue: false),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.borderLine(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Draft',
                      style: TextStyle(color: AppColors.primaryText(context)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reel shared!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Share Reel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionRow(
    String label,
    String value,
    IconData icon, {
    bool showValue = true,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.secondaryText(context), size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: AppColors.primaryText(context),
          fontSize: 15,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showValue && value.isNotEmpty)
            Text(
              value,
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 13,
              ),
            ),
          Icon(Iconsax.arrow_right_3,
              color: AppColors.mutedText(context), size: 18),
        ],
      ),
      onTap: () {},
    );
  }
}
