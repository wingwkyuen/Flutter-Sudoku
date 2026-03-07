import 'package:flutter/material.dart';

/// Helper function to show dialogs with fade and scale animations
Future<T?> showAnimatedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Duration duration = const Duration(milliseconds: 300),
  String? barrierLabel,
}) {
  return showGeneralDialog<T>(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: duration,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}
