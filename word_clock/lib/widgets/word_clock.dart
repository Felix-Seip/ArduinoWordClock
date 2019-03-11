import 'package:flutter/material.dart';
import 'clock_element.dart';

class WordClock extends StatefulWidget {
  List<String> _clockLetters = [];
  Color _currentColor = const Color.fromARGB(255, 0, 0, 0);
  final List<int> elementPositionsFrom = [
    66, //Eins
    73, //Zwei
    40, //Drei
    33, //Vier
    55, //Fünf
    22, //Sechs
    26, //Sieben
    18, //Acht
    3, //Neun
    0, //Zehn
    58, //Elf
    13, //Zwölf
    -1, //Null
    117, //Fünf
    106, //Zehn
    92, //Viertel
    99, //Zwanzig
    62 //Halb
  ];

  final List<int> elementPositionsTo = [
    69, //Eins
    76, //Zwei
    40, //Drei
    33, //Vier
    55, //Fünf
    22, //Sechs
    26, //Sieben
    18, //Acht
    3, //Neun
    0, //Zehn
    58, //Elf
    13, //Zwölf
    -1, //Null
    117, //Fünf
    106, //Zehn
    92, //Viertel
    99, //Zwanzig
    62 //Halb
  ];

  WordClock(this._clockLetters, this._currentColor);

  @override
  _WordClockState createState() => _WordClockState();
}

class _WordClockState extends State<WordClock> {
  Color _defaultColor = Color.fromARGB(255, 0, 0, 0);
  List<ClockElement> _clockElements;

  void setUpClockElements() {
    for (int i = 1; i <= 12; i++) {
      List<int> numericValues = [];
      numericValues[0] = i;

      if (i + 12 == 24) {
        numericValues[1] = 0;
      } else {
        numericValues[1] = i + 12;
      }

      _clockElements.add(
        ClockElement(_text, _defaultColor, widget.elementPositionsFrom[i - 1],
            widget.elementPositionsTo[i - 1], numericValues, ElementType.HOUR),
      );
    }
  }

  @override
  void initState() {
    _clockElements = widget._clockLetters
        .map(
          (title) => ClockElement(
                title,
                widget._currentColor,
              ),
        )
        .toList();
    setUpClockElements();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(50),
      child: GridView.count(
        crossAxisCount: 11,
        children: _clockElements,
      ),
    );
  }
}
