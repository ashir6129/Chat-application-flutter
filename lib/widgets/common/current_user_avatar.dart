import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/profile_memory_cache.dart';
import '../../core/profile_refresh.dart';
import '../feed/feed_user_avatar.dart';

/// Own profile avatar — updates instantly when photo changes or is removed.
class CurrentUserAvatar extends StatefulWidget {
  final double size;
  final bool showBorder;

  const CurrentUserAvatar({
    super.key,
    this.size = 40,
    this.showBorder = true,
  });

  @override
  State<CurrentUserAvatar> createState() => _CurrentUserAvatarState();
}

class _CurrentUserAvatarState extends State<CurrentUserAvatar> {
  late final ProfileRefreshListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = ({bool silent = false}) {
      if (mounted) setState(() {});
    };
    ProfileRefresh.register(_listener);
  }

  @override
  void dispose() {
    ProfileRefresh.unregister(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ProfileMemoryCache.me;
    final accent = AppColors.buttonColor(context);

    return FeedUserAvatar(
      name: me?.displayName ?? 'You',
      initials: me?.initials,
      accentColor: accent,
      imageUrl: me?.avatarUrl,
      size: widget.size,
      showBorder: widget.showBorder,
    );
  }
}
