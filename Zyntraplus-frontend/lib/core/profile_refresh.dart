typedef ProfileRefreshListener = void Function({bool silent});

/// Reload profile screens after edit/save.
class ProfileRefresh {
  ProfileRefresh._();

  static final List<ProfileRefreshListener> _listeners = [];

  static void register(ProfileRefreshListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  static void unregister([ProfileRefreshListener? listener]) {
    if (listener != null) {
      _listeners.remove(listener);
    } else {
      _listeners.clear();
    }
  }

  static void trigger({bool silent = true}) {
    for (final listener in List<ProfileRefreshListener>.from(_listeners)) {
      listener(silent: silent);
    }
  }
}
