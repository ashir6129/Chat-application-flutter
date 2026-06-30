import 'package:flutter/material.dart';

/// A global notifier that HomeScreen updates with its scroll offset.
/// MainScreen listens to this to animate the bottom navbar background.
class HomeScrollNotifier {
  HomeScrollNotifier._();
  static final instance = HomeScrollNotifier._();

  final ValueNotifier<double> scrollOffset = ValueNotifier(0.0);
}
