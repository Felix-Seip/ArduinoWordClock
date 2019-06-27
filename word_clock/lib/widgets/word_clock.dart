import 'package:flutter/material.dart';
import 'clock_element.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class WordClock extends StatefulWidget {
  List<String> _clockLetters = [];
  Color _currentColor = const Color.fromARGB(255, 0, 0, 255);
  bool _animate;

  WordClock(this._clockLetters, this._currentColor, this._animate);

  @override
  _WordClockState createState() => _WordClockState();
}

class _WordClockState extends State<WordClock> {
  List<ClockElement> _clockElements;
  Map<int, MapEntry<int, int>> _wordDefintions;

  Future<Map<int, MapEntry<int, int>>> _loadClockLetterIndices() {
    Map<int, MapEntry<int, int>> retVal = Map();
    return rootBundle
        .loadString('assets/clock_element_indices.txt')
        .then((String contents) {
      List<String> wordDefinitions = contents.split("\n");
      for (String wordDefinition in wordDefinitions) {
        List<String> index = wordDefinition.split(":");
        int wordIndex = int.parse(index[0]);
        int wordIndexFrom = int.parse(index[1].split(",")[0]);
        int wordIndexTo = int.parse(index[1].split(",")[1]);

        retVal[wordIndex] = MapEntry(wordIndexFrom, wordIndexTo);
      }

      return retVal;
    });
  }

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _showTime(final TimeOfDay currentTime) {
    print(currentTime);

    for (int i = 0; i < _clockElements.length; i++) {
      _clockElements[i].setColor(Colors.black);
    }

    for (MapEntry<int, MapEntry<int, int>> entry in _wordDefintions.entries) {
      int hour =
          currentTime.hour <= 12 ? currentTime.hour : currentTime.hour - 12;

      int minute = currentTime.minute;

      if (entry.key == -1 || entry.key == -2) {
        for (int i = entry.value.key; i <= entry.value.value; i++) {
          _clockElements[i].setColor(Colors.red);
        }
      }

      if (minute == 0 && entry.key == -6) {
        for (int i = entry.value.key; i <= entry.value.value; i++) {
          _clockElements[i].setColor(Colors.red);
        }
      }

      if (hour == entry.key) {
        for (int i = entry.value.key; i <= entry.value.value; i++) {
          _clockElements[i].setColor(Colors.red);
        }
      }

      if (minute == 30 && entry.key == -5) {
        for (int i = entry.value.key; i <= entry.value.value; i++) {
          _clockElements[i].setColor(Colors.red);
        }
      }

      if (((minute >= 20 && minute < 25) || (minute >= 40 && minute < 55)) &&
          entry.key == 20) {
        if (60 - minute > 35) {
          for (int i = _wordDefintions[-4].key;
              i <= _wordDefintions[-4].value;
              i++) {
            _clockElements[i].setColor(Colors.red);
          }
        } else {
          for (int i = _wordDefintions[-3].key;
              i <= _wordDefintions[-3].value;
              i++) {
            _clockElements[i].setColor(Colors.red);
          }
        }
        for (int i = entry.value.key; i <= entry.value.value; i++) {
          _clockElements[i].setColor(Colors.red);
        }
      }

      if (((minute >= 15 && minute < 20) || (minute >= 45 && minute < 50)) &&
          entry.key == 15) {
        if (60 - minute > 35) {
          for (int i = _wordDefintions[-4].key;
              i <= _wordDefintions[-4].value;
              i++) {
            _clockElements[i].setColor(Colors.red);
          }
        } else {
          for (int i = _wordDefintions[-3].key;
              i <= _wordDefintions[-3].value;
              i++) {
            _clockElements[i].setColor(Colors.red);
          }
        }
        for (int i = entry.value.key; i <= entry.value.value; i++) {
          _clockElements[i].setColor(Colors.red);
        }
      }

      if ((minute >= 10 || minute >= 50) && entry.key == 10) {
        if (60 - minute > 35) {
          for (int i = _wordDefintions[-4].key;
              i <= _wordDefintions[-4].value;
              i++) {
            _clockElements[i].setColor(Colors.red);
          }
        } else {
          for (int i = _wordDefintions[-3].key;
              i <= _wordDefintions[-3].value;
              i++) {
            _clockElements[i].setColor(Colors.red);
          }
        }
        for (int i = entry.value.key; i <= entry.value.value; i++) {
          _clockElements[i].setColor(Colors.red);
        }
      }

      if ((minute == 5 || minute == 55) && entry.key == 5) {
        if (60 - minute > 35) {
          for (int i = _wordDefintions[-4].key;
              i <= _wordDefintions[-4].value;
              i++) {
            _clockElements[i].setColor(Colors.red);
          }
        } else {
          for (int i = _wordDefintions[-3].key;
              i <= _wordDefintions[-3].value;
              i++) {
            _clockElements[i].setColor(Colors.red);
          }
        }
        for (int i = entry.value.key; i <= entry.value.value; i++) {
          _clockElements[i].setColor(Colors.red);
        }
      }
    }
  }

  void _checkTime() {
    Timer(
      Duration(seconds: 1),
      () {
        _showTime(TimeOfDay(
          hour: 3,
          minute: 40,
        ) // 3:00pm
            );
        _checkTime();
      },
    );
  }

  void _setup() {
    _clockElements = widget._clockLetters
        .map(
          (title) => ClockElement(
                title,
                widget._currentColor,
              ),
        )
        .toList();
    if (widget._animate) {
      _loadClockLetterIndices().then((value) {
        _wordDefintions = value;
        _checkTime();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(50),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 11,
        children: _clockElements,
      ),
    );
  }
}
