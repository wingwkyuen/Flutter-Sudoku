import 'package:flutter/material.dart';

import 'constants.dart';
import 'main.dart';
import 'styles.dart';

MaterialColor emptyColor(bool gameOver) =>
    gameOver ? Styles.primaryColor : Styles.secondaryColor;

// Returns the background color for a cell (theme-aware)
Color buttonColor(int k, int i, List<List<int>> game, List<List<int>> gameCopy,
    int? selectedRow, int? selectedCol, int? highlightNumber) {
  // Highlight cells with matching number
  if (highlightNumber != null && game[k][i] == highlightNumber) {
    return const Color.fromARGB(
        255, 22, 108, 230); // Light amber/yellow highlight
  }
  // Selected cell
  if (selectedRow == k && selectedCol == i) {
    return Styles.primaryColor.withValues(alpha: 0.3);
  }
  // Clue cell (given)
  if (gameCopy[k][i] != 0) {
    if (Styles.primaryBackgroundColor == Styles.darkGrey) {
      return Colors.grey[800]!;
    } else {
      return Colors.grey[300]!;
    }
  }
  // Empty cell
  return Styles.primaryBackgroundColor;
}

double buttonSize() {
  final screenWidth = MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.first)
      .size
      .width;

  // Calculate responsive button size with better spacing
  // 9 buttons per row + spacing = roughly 90% of screen width for modern appearance
  double responsiveSize = (screenWidth * 0.90) / 9;

  // Use minimum and maximum sizes for consistency with modern Material Design 3
  if (HomePageState.platform.contains(PLATFORM_ANDROID) ||
      HomePageState.platform.contains(PLATFORM_IOS)) {
    return responsiveSize.clamp(34.0, 75.0);
  }
  return responsiveSize.clamp(42.0, 80.0);
}

double buttonFontSize() {
  if (HomePageState.platform.contains(PLATFORM_ANDROID) ||
      HomePageState.platform.contains(PLATFORM_IOS)) {
    return BUTTON_FONT_SIZE_MOBILE;
  }
  return BUTTON_FONT_SIZE_DESKTOP;
}

BorderRadiusGeometry buttonEdgeRadius(int k, int i) {
  return BorderRadius.zero;
}

// Grid border with thicker lines for 3x3 sections and outer edge (theme-aware)
Border getGridBorder(int k, int i) {
  final color = Styles.foregroundColor;
  const normalWidth = 0.5;
  const thickWidth = 1.0;
  const outerWidth = 2.0; // Match the combined thickness of cross borders

  // Determine which borders should be thick
  final topThick = (k == 0 || k == 3 || k == 6);
  final bottomThick = (k == 2 || k == 5 || k == 8);
  final leftThick = (i == 0 || i == 3 || i == 6);
  final rightThick = (i == 2 || i == 5 || i == 8);

  // Outer edges
  final topOuter = (k == 0);
  final bottomOuter = (k == 8);
  final leftOuter = (i == 0);
  final rightOuter = (i == 8);

  return Border(
    top: BorderSide(
      color: color,
      width: topOuter ? outerWidth : (topThick ? thickWidth : normalWidth),
      style: BorderStyle.solid,
    ),
    bottom: BorderSide(
      color: color,
      width:
          bottomOuter ? outerWidth : (bottomThick ? thickWidth : normalWidth),
      style: BorderStyle.solid,
    ),
    left: BorderSide(
      color: color,
      width: leftOuter ? outerWidth : (leftThick ? thickWidth : normalWidth),
      style: BorderStyle.solid,
    ),
    right: BorderSide(
      color: color,
      width: rightOuter ? outerWidth : (rightThick ? thickWidth : normalWidth),
      style: BorderStyle.solid,
    ),
  );
}
