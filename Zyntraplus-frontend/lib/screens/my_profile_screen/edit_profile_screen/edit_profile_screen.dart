import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zyntraplus/api_services/media_service.dart';
import 'package:zyntraplus/api_services/user_service.dart';
import 'package:zyntraplus/core/profile_avatar_sync.dart';
import 'package:zyntraplus/core/profile_refresh.dart';
import 'package:zyntraplus/models/user_profile.dart';
import 'package:zyntraplus/widgets/post/media_editor_screen.dart';
import '../../../core/app_colors.dart';
import '../../../widgets/feed/feed_user_avatar.dart';

enum _AvatarPickAction { camera, gallery, remove }

class EditProfileScreen extends StatefulWidget {
  final UserProfile? initialProfile;

  const EditProfileScreen({super.key, this.initialProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _usernameCtrl;
  bool _saving = false;
  bool _loading = true;
  bool _uploadingPhoto = false;
  UserProfile? _profile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bioCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _websiteCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    if (widget.initialProfile != null) {
      _applyProfile(widget.initialProfile!);
      setState(() => _loading = false);
      return;
    }

    try {
      final profile = await UserService.getMe();
      if (!mounted) return;
      _applyProfile(profile);
      setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyProfile(UserProfile profile) {
    _profile = profile;
    _bioCtrl.text = profile.bio;
    _locationCtrl.text = profile.location ?? '';
    _websiteCtrl.text = profile.website ?? '';
    _usernameCtrl.text = profile.username;
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _websiteCtrl.dispose();
    _usernameCtrl.dispose();
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
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText(context)),
          onPressed: _saving ? null : () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: AppColors.primaryText(context), fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _onSave,
            child: _saving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.buttonColor(context)),
                  )
                : Text(
                    'Save',
                    style: TextStyle(color: AppColors.buttonColor(context), fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.buttonColor(context)))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _uploadingPhoto ? null : _pickAvatar,
                          child: Stack(
                            children: [
                              FeedUserAvatar(
                                name: _profile?.displayName ?? 'You',
                                initials: _profile?.initials,
                                accentColor: AppColors.buttonColor(context),
                                imageUrl: _profile?.avatarUrl,
                                size: 90,
                                showBorder: true,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.buttonColor(context),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primaryBackground(context), width: 2),
                                  ),
                                  child: _uploadingPhoto
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _uploadingPhoto ? null : _pickAvatar,
                          child: Text(
                            'Change profile photo',
                            style: TextStyle(color: AppColors.buttonColor(context), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _inputField(
                    'Username',
                    _usernameCtrl,
                    prefix: '@',
                    hintText: 'your_username',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Letters, numbers, and underscores only (3–50 characters)',
                    style: TextStyle(color: AppColors.mutedText(context), fontSize: 11),
                  ),
                  const SizedBox(height: 14),
                  _inputField('Bio', _bioCtrl, maxLines: 3),
                  const SizedBox(height: 14),
                  _inputField('Location', _locationCtrl),
                  const SizedBox(height: 14),
                  _inputField('Website', _websiteCtrl),
                ],
              ),
            ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? prefix,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.secondaryText(context), fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: AppColors.primaryText(context)),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.secondaryBackground(context),
            prefixText: prefix,
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.mutedText(context)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLine(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.buttonColor(context)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAvatar() async {
    final hasPhoto =
        _profile?.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty;

    final action = await showModalBottomSheet<_AvatarPickAction>(
      context: context,
      backgroundColor: AppColors.secondaryBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Iconsax.camera, color: AppColors.buttonColor(ctx)),
              title: Text('Camera', style: TextStyle(color: AppColors.primaryText(ctx))),
              onTap: () => Navigator.pop(ctx, _AvatarPickAction.camera),
            ),
            ListTile(
              leading: Icon(Iconsax.gallery, color: AppColors.buttonColor(ctx)),
              title: Text('Gallery', style: TextStyle(color: AppColors.primaryText(ctx))),
              onTap: () => Navigator.pop(ctx, _AvatarPickAction.gallery),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Iconsax.trash, color: Color(0xFFE57373)),
                title: const Text(
                  'Remove photo',
                  style: TextStyle(color: Color(0xFFE57373)),
                ),
                onTap: () => Navigator.pop(ctx, _AvatarPickAction.remove),
              ),
          ],
        ),
      ),
    );

    if (action == null || !mounted) return;

    if (action == _AvatarPickAction.remove) {
      await _removeAvatar();
      return;
    }

    final source = action == _AvatarPickAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    try {
      final file = await _picker.pickImage(source: source, imageQuality: 92);
      if (file == null || !mounted) return;

      final bytes = await file.readAsBytes();
      final filename = file.name.trim().isEmpty ? 'avatar.jpg' : file.name;

      final edited = await MediaEditorScreen.open(
        context,
        bytes: bytes,
        filename: filename,
        isVideo: false,
      );

      if (!mounted || edited == null || edited.removed) return;

      setState(() => _uploadingPhoto = true);

      final urls = await MediaService.uploadFiles(
        bytesList: [edited.bytes],
        filenames: [edited.filename],
      );

      if (urls.isEmpty) throw Exception('Upload failed');

      final profile = await UserService.updateAvatar(urls.first);
      ProfileAvatarSync.apply(profile);

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _uploadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserService.errorMessage(e))),
      );
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _uploadingPhoto = true);
    try {
      final profile = await UserService.updateAvatar(null);
      ProfileAvatarSync.apply(profile);

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _uploadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo removed')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserService.errorMessage(e))),
      );
    }
  }

  Future<void> _onSave() async {
    final username = _usernameCtrl.text.trim().toLowerCase();
    if (username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username must be at least 3 characters')),
      );
      return;
    }
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username can only use letters, numbers, and underscores')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await UserService.updateMe(
        username: username,
        bio: _bioCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        website: _websiteCtrl.text.trim(),
      );
      ProfileRefresh.trigger(silent: true);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserService.errorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
