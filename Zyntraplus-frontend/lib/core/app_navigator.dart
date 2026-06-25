import 'package:flutter/material.dart';

/// Root navigator key — required for navigation from MaterialApp.builder
/// (IncomingCallOverlay sits above the Navigator, not inside it).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
