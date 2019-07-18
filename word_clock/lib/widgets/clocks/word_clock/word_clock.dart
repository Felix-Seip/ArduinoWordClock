import 'package:flutter/material.dart';
import 'clock_element.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

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

    int hour =
        currentTime.hour <= 12 ? currentTime.hour : currentTime.hour - 12;

    int minute = currentTime.minute;

    MapEntry<int, int> entr = _findClockElement(minute, true);

    for (MapEntry<int, MapEntry<int, int>> entry in _wordDefintions.entries) {
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

      if (minute == 30 && entry.key == -5) {
        for (int i = entry.value.key; i <= entry.value.value; i++) {
          _clockElements[i].setColor(Colors.red);
        }
        hour++;
      }
    }

    if (entr != null) {
      for (int i = entr.key; i <= entr.value; i++) {
        _clockElements[i].setColor(Colors.red);
      }
    }

    if (60 - minute > 35 &&
        minute != 0 &&
        minute != 35 &&
        minute != 25 &&
        minute != 30) {
      for (int i = _wordDefintions[-4].key;
          i <= _wordDefintions[-4].value;
          i++) {
        _clockElements[i].setColor(Colors.red);
      }
    } else if (minute != 0 && minute != 35 && minute != 25 && minute != 30) {
      for (int i = _wordDefintions[-3].key;
          i <= _wordDefintions[-3].value;
          i++) {
        _clockElements[i].setColor(Colors.red);
      }
      hour++;
    }

    if (minute == 25) {
      for (int i = _wordDefintions[-3].key;
          i <= _wordDefintions[-3].value;
          i++) {
        _clockElements[i].setColor(Colors.red);
      }
      for (int i = _wordDefintions[-5].key;
          i <= _wordDefintions[-5].value;
          i++) {
        _clockElements[i].setColor(Colors.red);
      }
      hour++;
    } else if (minute == 35) {
      for (int i = _wordDefintions[-4].key;
          i <= _wordDefintions[-4].value;
          i++) {
        _clockElements[i].setColor(Colors.red);
      }
      for (int i = _wordDefintions[-5].key;
          i <= _wordDefintions[-5].value;
          i++) {
        _clockElements[i].setColor(Colors.red);
      }
      hour++;
    }

    entr = _findClockElement(hour, false);
    for (int i = entr.key; i <= entr.value; i++) {
      _clockElements[i].setColor(Colors.red);
    }
  }

  MapEntry<int, int> _findClockElement(int value, final bool isMinute) {
    int startIndex = 0;
    if (!isMinute) {
      startIndex = 9;
      if (value > 12) {
        value = value - 12;
      }
    }

    if (isMinute) {
      value = value - (value % 5);
    }

    if (isMinute) {
      switch (value) {
        case 5:
        case 55:
          value = -10;
          break;
        case 10:
        case 50:
          value = -11;
          break;
        case 15:
        case 45:
          value = -12;
          break;
        case 20:
        case 40:
          value = -13;
          break;
        case 25:
        case 35:
          value = -10;
          break;
        default:
      }
    }

    for (int i = startIndex; i < _wordDefintions.entries.length; i++) {
      if (_wordDefintions.entries.toList()[i].key == value) {
        return _wordDefintions.entries.toList()[i].value;
      }
    }
    return null;
  }

  void _checkTime() {
    Timer(
      Duration(seconds: 1),
      () {
        _showTime(
          TimeOfDay(
            hour: DateTime.now().hour,
            minute: DateTime.now().minute,
          ),
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
