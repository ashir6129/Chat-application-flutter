import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_colors.dart';

void showChatAttachSheet(BuildContext context, {Function(String)? onImageSelected}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ChatAttachSheet(onImageSelected: onImageSelected),
  );
}

class _ChatAttachSheet extends StatelessWidget {
  final Function(String)? onImageSelected;
  const _ChatAttachSheet({this.onImageSelected});

  static const _items = [
    _AttachItem(Iconsax.gallery, 'Photos', Color(0xFF43A047)),
    _AttachItem(Iconsax.camera, 'Camera', Color(0xFFE91E63)),
    _AttachItem(Iconsax.document, 'File', Color(0xFF2196F3)),
    _AttachItem(Iconsax.location, 'Location', Color(0xFF00BFA5)),
    _AttachItem(Iconsax.user, 'Contact', Color(0xFF9C27B0)),
    _AttachItem(Iconsax.chart_2, 'Poll', Color(0xFFFF9800)),
    _AttachItem(Iconsax.gift, 'Gift', Color(0xFFFF6584)),
    _AttachItem(Iconsax.microphone_2, 'Audio', Color(0xFFFF5722)),
  ];

  Future<void> _handleImageTap(BuildContext context, bool fromCamera) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    
    if (image != null && onImageSelected != null) {
      Navigator.pop(context);
      onImageSelected!(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedText(context),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 18,
              crossAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.9,
              children: _items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return GestureDetector(
                  onTap: () async {
                    if (item.label == 'Photos') {
                      await _handleImageTap(context, false);
                    } else if (item.label == 'Camera') {
                      await _handleImageTap(context, true);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(item.icon, color: item.color, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachItem {
  final IconData icon;
  final String label;
  final Color color;
  const _AttachItem(this.icon, this.label, this.color);
}
