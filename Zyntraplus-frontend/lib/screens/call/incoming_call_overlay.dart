import 'package:flutter/material.dart';

/// Legacy wrapper — call UI is opened via [CallUi] + root navigator key.
class IncomingCallOverlay extends StatelessWidget {
  final Widget child;

  const IncomingCallOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
