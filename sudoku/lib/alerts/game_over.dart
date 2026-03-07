import 'package:flutter/material.dart';

import '../styles.dart';

class AlertGameOver extends StatelessWidget {
  static bool newGame = false;
  static bool restartGame = false;
  final String timeString;

  const AlertGameOver({Key? key, required this.timeString}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Styles.secondaryBackgroundColor,
      title: Text(
        'Congratulations!',
        style: TextStyle(color: Styles.foregroundColor),
      ),
      content: Text(
        'You successfully solved the Sudoku\nTime: $timeString',
        style: TextStyle(color: Styles.foregroundColor),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
              foregroundColor:
                  WidgetStateProperty.all<Color>(Styles.primaryColor)),
          onPressed: () {
            Navigator.pop(context);
            restartGame = true;
          },
          child: const Text('Restart Game'),
        ),
        TextButton(
          style: ButtonStyle(
              foregroundColor:
                  WidgetStateProperty.all<Color>(Styles.primaryColor)),
          onPressed: () {
            Navigator.pop(context);
            newGame = true;
          },
          child: const Text('New Game'),
        ),
      ],
    );
  }
}
