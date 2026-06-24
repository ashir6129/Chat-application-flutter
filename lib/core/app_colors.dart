import 'package:flutter/material.dart';

class AppColors {

  ///Background Colors
  static Color primaryBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121B22)
          : const Color(0xFFFFFFFF);

  /// Composer / search field pill background (dark theme).
  static Color composerBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF202C33)
          : const Color(0xFFF0F2F5);

  static Color secondaryBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1F2C34)
          : const Color(0xFFF5F5F5);

  static Color bottomNavBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF161C24).withOpacity(0.9)
          : const Color(0xFFFFFFFF).withOpacity(0.9);

  ///Text Colors
  static Color primaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFE9EDEF)
          : const Color(0xFF0D0D0D);

  static Color secondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF8696A0)
          : const Color(0xFF555555);

  static Color mutedText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF667781)
          : const Color(0xFFB0BEC5);

  ///Border Line Colors
  static Color borderLine(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3B4A54)
          : const Color(0xFFE0E0E0);

  ///Button Colors
  static Color buttonColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF00A884)
          : const Color(0xFF007AFF);

  static Color buttonTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0D0D0D)
          : const Color(0xFFFFFFFF);

  ///Others
  static Color liveBadge(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFFF3B3B)
          : const Color(0xFFE53935);

  static Color heartColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFFF4D6D)
          : const Color(0xFFE91E63);

  static Color verifiedBadge(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3D9BFF)
          : const Color(0xFF1976D2);
}