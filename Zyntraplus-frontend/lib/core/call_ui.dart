import 'package:flutter/material.dart';
import '../screens/call/call_screen.dart';
import 'app_navigator.dart';

/// Pushes the full-screen call UI onto the root navigator.
abstract final class CallUi {
  static bool _isOpen = false;

  static bool get isOpen => _isOpen;

  /// Open call screen from a widget [context] (outgoing calls — most reliable).
  static void show(BuildContext context) {
    if (_isOpen) return;
    final nav = Navigator.of(context, rootNavigator: true);
    _push(nav);
  }

  /// Open call screen without context (incoming calls).
  static void showFromRoot({int attempt = 0}) {
    if (_isOpen) return;
    final nav = rootNavigatorKey.currentState;
    if (nav != null) {
      _push(nav);
      return;
    }
    if (attempt < 10) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showFromRoot(attempt: attempt + 1);
      });
    } else {
      debugPrint('CallUi: could not find root navigator after retries');
    }
  }

  static void _push(NavigatorState nav) {
    _isOpen = true;
    nav
        .push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        settings: const RouteSettings(name: '/call'),
        builder: (_) => const CallScreen(),
      ),
    )
        .whenComplete(() {
      _isOpen = false;
    });
  }

  static void close([BuildContext? context]) {
    if (!_isOpen) return;
    final nav = context != null
        ? Navigator.maybeOf(context, rootNavigator: true)
        : rootNavigatorKey.currentState;
    nav?.maybePop();
    _isOpen = false;
  }
}
