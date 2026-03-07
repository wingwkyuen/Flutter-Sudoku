import 'package:flutter/material.dart';

import '../styles.dart';

class AlertNumbersState extends StatefulWidget {
  const AlertNumbersState({Key? key}) : super(key: key);

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
    // Calculate responsive button size with modern Material Design 3 spacing
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = ((screenWidth * 0.65) / 3) - 12; // 3 buttons per row with spacing
    final fontSize = (screenWidth * 0.13).clamp(22.0, 32.0);
    
    return <SizedBox>[
      for (int numbers in numberList)
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: TextButton(
            onPressed: () => {
              setState(() {
                numberSelected = numbers;
                number = numberSelected;
                Navigator.pop(context);
              })
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return Styles.primaryColor.withValues(alpha: 0.1);
                  }
                  if (states.contains(WidgetState.pressed)) {
                    return Styles.primaryColor.withValues(alpha: 0.2);
                  }
                  return Styles.secondaryBackgroundColor;
                },
              ),
              foregroundColor: WidgetStateProperty.all<Color>(Styles.primaryColor),
              shape: WidgetStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              )),
              side: WidgetStateProperty.all<BorderSide>(BorderSide(
                color: Styles.foregroundColor.withValues(alpha: 0.3),
                width: 1.5,
                style: BorderStyle.solid,
              )),
              elevation: WidgetStateProperty.resolveWith<double>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return 2.0;
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return 4.0;
                  }
                  return 1.0;
                },
              ),
              shadowColor: WidgetStateProperty.all<Color>(
                  Styles.primaryColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              numbers.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: Styles.secondaryBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose a Number',
              style: TextStyle(
                color: Styles.foregroundColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: oneRow(numberList1),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
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
