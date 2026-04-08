import 'package:flutter/material.dart';

/// App-wide color palette matching the Swift AppColors.swift exactly.
/// Uses BuildContext to detect dark/light theme, mirroring NSAppearance logic.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ---------------------------------------------------------------------------
  // Background (Apple Binary: pure black / light gray)
  // ---------------------------------------------------------------------------

  static Color background(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF000000) // #000000
          : const Color(0xFFF5F5F7); // #f5f5f7

  // ---------------------------------------------------------------------------
  // Text (Apple Hierarchy)
  // ---------------------------------------------------------------------------

  static Color primaryText(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFFFFFFF) // #ffffff
          : const Color(0xFF1D1D1F); // #1d1d1f

  static Color secondaryText(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.60)
          : Colors.black.withValues(alpha: 0.48);

  static Color tertiaryText(BuildContext context) =>
      _isDark(context)
          ? Colors.white.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.25);

  // ---------------------------------------------------------------------------
  // Accent (Apple Blue)
  // ---------------------------------------------------------------------------

  static Color accent(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF2997FF) // #2997ff
          : const Color(0xFF0071E3); // #0071e3

  static Color danger(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFFF453A) // #ff453a
          : const Color(0xFFFF3B30); // #ff3b30

  // ---------------------------------------------------------------------------
  // Surface
  // ---------------------------------------------------------------------------

  static Color surface(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF1C1C1E) // #1c1c1e
          : const Color(0xFFFFFFFF); // #ffffff

  // ---------------------------------------------------------------------------
  // Legacy Aliases (backward compatibility)
  // ---------------------------------------------------------------------------

  static Color backgroundGradientTop(BuildContext context) =>
      background(context);
  static Color backgroundGradientBottom(BuildContext context) =>
      background(context);
  static Color titleText(BuildContext context) => primaryText(context);
  static Color subtitleText(BuildContext context) => secondaryText(context);
  static Color rightPanelText(BuildContext context) => secondaryText(context);
  static Color progressText(BuildContext context) => accent(context);
  static Color accentBlue(BuildContext context) => accent(context);
  static Color buttonTint(BuildContext context) => accent(context);
  static Color startButton(BuildContext context) => accent(context);
  static Color pauseButton(BuildContext context) => accent(context);
  static Color stopButton(BuildContext context) => danger(context);
  static Color bannerTitle(BuildContext context) => accent(context);
  static Color panelBackground(BuildContext context) => surface(context);
  static Color rightPanelGradientTop(BuildContext context) =>
      background(context);
  static Color rightPanelGradientBottom(BuildContext context) =>
      background(context);
  static Color historyHeaderBackground(BuildContext context) =>
      surface(context);
  static Color historySessionTime(BuildContext context) => accent(context);
  static Color historyIcon(BuildContext context) => accent(context);
  static Color calendarEmptyCell(BuildContext context) => surface(context);
  static Color calendarEmptyCellBorder(BuildContext context) =>
      tertiaryText(context);

  // ---------------------------------------------------------------------------
  // Water (Natural colors preserved)
  // ---------------------------------------------------------------------------

  static Color waterGradientTop(BuildContext context) =>
      _isDark(context)
          ? const Color.fromRGBO(77, 166, 230, 1.0)
          : const Color.fromRGBO(100, 202, 247, 1.0);

  static Color waterGradientBottom(BuildContext context) =>
      _isDark(context)
          ? const Color.fromRGBO(26, 89, 191, 1.0)
          : const Color.fromRGBO(36, 122, 232, 1.0);

  static Color dropGradientTop(BuildContext context) =>
      _isDark(context)
          ? const Color.fromRGBO(128, 199, 255, 1.0)
          : const Color.fromRGBO(166, 227, 255, 1.0);

  static Color dropGradientBottom(BuildContext context) =>
      _isDark(context)
          ? const Color.fromRGBO(31, 115, 217, 1.0)
          : const Color.fromRGBO(46, 148, 242, 1.0);

  static Color cloudColor(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFFFFFFFF) // white
          : const Color.fromRGBO(102, 102, 102, 1.0); // 0.4 gray

  // ---------------------------------------------------------------------------
  // Static accessors (for use outside widget tree, e.g. BucketSkin defaults)
  // ---------------------------------------------------------------------------

  static const Color waterGradientTopColor =
      Color.fromRGBO(77, 166, 230, 1.0);
  static const Color waterGradientBottomColor =
      Color.fromRGBO(26, 89, 191, 1.0);
  static const Color dropGradientTopColor =
      Color.fromRGBO(128, 199, 255, 1.0);
  static const Color dropGradientBottomColor =
      Color.fromRGBO(31, 115, 217, 1.0);

  // ---------------------------------------------------------------------------
  // Sky Gradients (session progress)
  // ---------------------------------------------------------------------------

  static Color skyDawnTop(BuildContext context) =>
      _isDark(context)
          ? const Color.fromRGBO(20, 15, 31, 1.0)
          : const Color.fromRGBO(245, 235, 224, 1.0);

  static Color skyDawnBottom(BuildContext context) =>
      _isDark(context)
          ? const Color.fromRGBO(15, 10, 10, 1.0)
          : const Color.fromRGBO(240, 230, 214, 1.0);

  static Color skyGatheringTop(BuildContext context) =>
      _isDark(context)
          ? const Color.fromRGBO(10, 10, 20, 1.0)
          : const Color.fromRGBO(217, 224, 235, 1.0);

  static Color skyGatheringBottom(BuildContext context) =>
      _isDark(context)
          ? const Color.fromRGBO(5, 5, 15, 1.0)
          : const Color.fromRGBO(209, 219, 230, 1.0);

  static Color skyStormTop(BuildContext context) =>
      _isDark(context)
          ? const Color.fromRGBO(5, 5, 10, 1.0)
          : const Color.fromRGBO(179, 189, 204, 1.0);

  static Color skyStormBottom(BuildContext context) =>
      _isDark(context)
          ? const Color.fromRGBO(0, 0, 5, 1.0)
          : const Color.fromRGBO(166, 179, 194, 1.0);

  static Color skyClearingTop(BuildContext context) =>
      _isDark(context)
          ? const Color.fromRGBO(26, 20, 10, 1.0)
          : const Color.fromRGBO(255, 245, 224, 1.0);

  static Color skyClearingBottom(BuildContext context) =>
      _isDark(context)
          ? const Color.fromRGBO(15, 10, 5, 1.0)
          : const Color.fromRGBO(250, 235, 204, 1.0);
}
