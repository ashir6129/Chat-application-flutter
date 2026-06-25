/// Lets nested profile screens switch the main bottom-nav tab without pushing duplicates.
class MainTabNavigation {
  MainTabNavigation._();

  static void Function(int index)? _switchTab;

  static void bind(void Function(int index) handler) {
    _switchTab = handler;
  }

  static void unbind() {
    _switchTab = null;
  }

  static void goTo(int index) {
    _switchTab?.call(index);
  }
}
