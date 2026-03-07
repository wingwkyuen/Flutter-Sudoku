import 'package:flutter/material.dart';

import 'constants.dart';
import 'main.dart';
import 'styles.dart';

MaterialColor emptyColor(bool gameOver) =>
    gameOver ? Styles.primaryColor : Styles.secondaryColor;

Color buttonColor(int k, int i) {
  Color color;
  if (([0, 1, 2].contains(k) && [3, 4, 5].contains(i)) ||
      ([3, 4, 5].contains(k) && [0, 1, 2, 6, 7, 8].contains(i)) ||
      ([6, 7, 8].contains(k) && [3, 4, 5].contains(i))) {
    if (Styles.primaryBackgroundColor == Styles.darkGrey) {
      color = Colors.grey[800]!;
    } else {
      color = Colors.grey[200]!;
    }
  } else {
    color = Styles.primaryBackgroundColor;
  }

  return color;
}

double buttonSize() {
  final screenWidth = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first).size.width;
  
  // Calculate responsive button size with better spacing
  // 9 buttons per row + spacing = roughly 65% of screen width for modern appearance
  double responsiveSize = (screenWidth * 0.65) / 9;
  
  // Use minimum and maximum sizes for consistency with modern Material Design 3
  if (HomePageState.platform.contains(PLATFORM_ANDROID) ||
      HomePageState.platform.contains(PLATFORM_IOS)) {
    return responsiveSize.clamp(34.0, 52.0);
  }
  return responsiveSize.clamp(42.0, 68.0);
}

double buttonFontSize() {
  if (HomePageState.platform.contains(PLATFORM_ANDROID) ||
      HomePageState.platform.contains(PLATFORM_IOS)) {
    return BUTTON_FONT_SIZE_MOBILE;
  }
  return BUTTON_FONT_SIZE_DESKTOP;
}

BorderRadiusGeometry buttonEdgeRadius(int k, int i) {
  if (k == 0 && i == 0) {
    return const BorderRadius.only(topLeft: Radius.circular(5));
  } else if (k == 0 && i == 8) {
    return const BorderRadius.only(topRight: Radius.circular(5));
  } else if (k == 8 && i == 0) {
    return const BorderRadius.only(bottomLeft: Radius.circular(5));
  } else if (k == 8 && i == 8) {
    return const BorderRadius.only(bottomRight: Radius.circular(5));
  }
  return BorderRadius.circular(0);
}

// Get border styling for grid lines - professional Sudoku grid layout
BorderSide getGridBorder(int k, int i) {
  // Determine section edges (3x3 boxes)
  bool isRightSectionEdge = (i + 1) % 3 == 0 && i != 8;
  bool isBottomSectionEdge = (k + 1) % 3 == 0 && k != 8;
  bool isLastColumn = i == 8;
  bool isLastRow = k == 8;
  bool isFirstColumn = i == 0;
  bool isFirstRow = k == 0;
  
  // Thick, prominent borders for 3x3 section edges and outer border
  if (isRightSectionEdge || isLastColumn || isBottomSectionEdge || isLastRow || isFirstColumn || isFirstRow) {
    return BorderSide(
      color: Styles.foregroundColor,
      width: (isFirstColumn || isLastColumn || isFirstRow || isLastRow) ? 3.0 : 2.0,
      style: BorderStyle.solid,
    );
  }
  
  // Thinner, subtle borders for individual cells
  return BorderSide(
    color: Styles.foregroundColor.withValues(alpha: 0.4),
    width: 0.8,
    style: BorderStyle.solid,
  );
}
