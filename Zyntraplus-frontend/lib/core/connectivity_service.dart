import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ValueNotifier<bool> onlineNotifier = ValueNotifier(true);
  static bool get isOnline => onlineNotifier.value;

  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static Future<void> init() async {
    final results = await Connectivity().checkConnectivity();
    _update(results);

    _subscription?.cancel();
    _subscription = Connectivity().onConnectivityChanged.listen(_update);
  }

  static void _update(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (onlineNotifier.value != online) {
      onlineNotifier.value = online;
    }
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
