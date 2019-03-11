import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'package:word_clock/widgets/word_clock.dart';

import 'dart:async';

class HomeScreen extends StatefulWidget {
  final BluetoothDevice _wordClock;
  final Function _connectToClock;
  final Function _disconnectFromClock;

  HomeScreen(this._wordClock, this._connectToClock, this._disconnectFromClock);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color currentColor = const Color.fromARGB(255, 0, 0, 0);
  TimeOfDay _time = TimeOfDay.now();
  List<String> _clockLetters;

  Future<List<String>> _loadClockLetters() {
    return rootBundle
        .loadString('assets/clock_text.txt')
        .then((String contents) {
      return contents.split(" ");
    });
  }

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
    });
    print(currentColor);
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    if (time != null) {
      _time = time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Clock'),
        backgroundColor: Color.fromARGB(255, 10, 9, 8),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.color_lens),
            tooltip: 'Change LED color',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    titlePadding: const EdgeInsets.all(0.0),
                    contentPadding: const EdgeInsets.all(0.0),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: currentColor,
                        onColorChanged: changeColor,
                        colorPickerWidth: 1000.0,
                        pickerAreaHeightPercent: 0.7,
                        enableAlpha: true,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.access_time),
            tooltip: 'Change clock time',
            onPressed: () {
              selectTime(context);
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 242, 244, 243),
      body: new FutureBuilder<List<String>>(
        future: _loadClockLetters(), // a Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            return WordClock(snapshot.data, currentColor);
          } else {
            return new Container();
          }
        },
      ),
    );
  }
}
