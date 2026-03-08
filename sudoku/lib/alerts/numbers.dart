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
    final buttonSize = ((screenWidth * 0.45) / 3) - 8;
    final fontSize = (screenWidth * 0.08).clamp(16.0, 22.0);

    return <SizedBox>[
      for (int numbers in numberList)
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Container(
            decoration: BoxDecoration(
              color: widget.currentValue == numbers
                  ? Colors.amberAccent // Highlight color
                  : (Styles.primaryBackgroundColor == Styles.darkGrey
                      ? Colors.grey[800]
                      : Colors.grey[300]),
              border: Border.all(color: Styles.foregroundColor, width: 1.0),
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
                    RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
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
                    fontWeight: FontWeight.bold,
                    color: Styles.foregroundColor,
                    letterSpacing: 0.3,
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 2,
      backgroundColor: Styles.primaryBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose a Number',
              style: TextStyle(
                color: Styles.foregroundColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 16),
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
