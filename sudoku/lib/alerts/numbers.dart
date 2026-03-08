import 'package:flutter/material.dart';

import '../styles.dart';

class AlertNumbersState extends StatefulWidget {
  final int? currentValue;
  const AlertNumbersState({Key? key, this.currentValue}) : super(key: key);

  @override
  AlertNumbers createState() => AlertNumbers();

  static int? get number {
    return AlertNumbers.number;
  }

  static set number(int? number) {
    AlertNumbers.number = number;
  }
}

class AlertNumbers extends State<AlertNumbersState> {
  // ignore: avoid_init_to_null
  static int? number = null;
  late int numberSelected;
  static final List<int> numberList1 = [1, 2, 3];
  static final List<int> numberList2 = [4, 5, 6];
  static final List<int> numberList3 = [7, 8, 9];

  List<SizedBox> createButtons(List<int> numberList) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth * 0.75).clamp(260.0, 360.0);
    final buttonSize = ((dialogWidth - 48) / 3) - 8;
    final fontSize = (buttonSize * 0.35).clamp(16.0, 24.0);

    return <SizedBox>[
      for (int numbers in numberList)
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: widget.currentValue == numbers
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.amber[300]!, Colors.orange[400]!],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Styles.primaryBackgroundColor == Styles.darkGrey
                            ? Colors.grey[700]!
                            : Colors.grey[200]!,
                        Styles.primaryBackgroundColor == Styles.darkGrey
                            ? Colors.grey[800]!
                            : Colors.grey[300]!,
                      ],
                    ),
              border: Border.all(
                color: widget.currentValue == numbers
                    ? Colors.orange[600]!
                    : Styles.foregroundColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (widget.currentValue == numbers
                          ? Colors.orange
                          : Styles.foregroundColor)
                      .withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  if (widget.currentValue == numbers) {
                    // If clicking the highlighted (already filled) number, remove it
                    numberSelected = 0;
                    number = 0;
                  } else {
                    numberSelected = numbers;
                    number = numberSelected;
                  }
                  Navigator.pop(context);
                });
              },
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.transparent),
                foregroundColor:
                    WidgetStateProperty.all<Color>(Styles.foregroundColor),
                shape: WidgetStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                elevation: WidgetStateProperty.all<double>(0),
                shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
                overlayColor:
                    WidgetStateProperty.all<Color>(Colors.transparent),
                padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
              ),
              child: Center(
                child: Text(
                  numbers.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: widget.currentValue == numbers
                        ? Colors.white
                        : Styles.foregroundColor,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
    ];
  }

  Row oneRow(List<int> numberList) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: createButtons(numberList),
    );
  }

  List<Row> createRows() {
    List<List<int>> numberLists = [numberList1, numberList2, numberList3];
    List<Row> rowList = <Row>[];
    for (var i = 0; i <= 2; i++) {
      rowList.add(oneRow(numberLists[i]));
    }
    return rowList;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth * 0.75).clamp(260.0, 360.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      backgroundColor: Styles.primaryBackgroundColor,
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose a Number',
              style: TextStyle(
                color: Styles.foregroundColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: oneRow(numberList1),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: oneRow(numberList2),
                ),
                oneRow(numberList3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
