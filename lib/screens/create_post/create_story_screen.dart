import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/app_colors.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final TextEditingController _captionCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(
        child: Stack(
          children: [
            _mediaPreview(),

            _topBar(),

            _bottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _mediaPreview() {
    return GestureDetector(
      onTap: () {
        // TODO: open camera / gallery
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.primaryBackground(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.camera,
                size: 48,
                color: Colors.white70,
              ),
              const SizedBox(height: 10),
              const Text(
                "Tap to add story",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Row(
        children: [
          _circleBtn(Icons.close, () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _bottomControls() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: _captionCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Add a caption...",
                hintStyle: TextStyle(color: AppColors.secondaryText(context)),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _circleBtn(Iconsax.gallery, () {
                // TODO: pick from gallery
              }),

              const Spacer(),

              GestureDetector(
                onTap: _onPost,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor(context),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.send_1, color: AppColors.buttonTextColor(context), size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Your Story",
                        style: TextStyle(
                          color: AppColors.buttonTextColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryText(context), size: 20),
      ),
    );
  }

  void _onPost() {
    final caption = _captionCtrl.text;

    // TODO: upload story

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Story posted")),
    );
  }
}