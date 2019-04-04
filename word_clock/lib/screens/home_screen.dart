import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../dialogs/color_picker_dialog.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flushbar/flushbar.dart';

import 'package:word_clock/widgets/word_clock.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final FlutterBlue _flutterBlue;
  final BluetoothDevice _wordClock;
  final Function _connectToClock;
  final Function _disconnectFromClock;
  final Function _setClockColor;
  final Function _setClockTime;

  HomeScreen(
    this._flutterBlue,
    this._wordClock,
    this._connectToClock,
    this._disconnectFromClock,
    this._setClockColor,
    this._setClockTime,
  );

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color currentColor = Color.fromARGB(255, 0, 0, 0);
  List<String> _clockLetters;

  /*
   * Load the clock letters to be displayed on the main screen. 
   * These letters are used as a preview for the actual word clock.
   */
  Future<List<String>> _loadClockLetters() {
    return rootBundle
        .loadString('assets/clock_text.txt')
        .then((String contents) {
      return contents.split(" ");
    });
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (
        BuildContext context,
        Widget child,
      ) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    if (time != null) {
      widget._setClockTime(time);
    }
  }

  void _startBluetoothConnectionListener() {
    widget._flutterBlue.onStateChanged().listen((BluetoothState onData) {
      if (onData == BluetoothState.off) {
        Flushbar(
          duration: Duration(seconds: 5),
          message: "Die Verbindung mit der Wortuhr ist fehlgeschlagen, " +
              "da die Bluetooth Funktion deaktiviert wurde.",
          flushbarPosition: FlushbarPosition.BOTTOM,
          backgroundColor: Colors.red,
        ).show(context);
      } else if (onData == BluetoothState.on) {
        Flushbar(
          duration: Duration(seconds: 5),
          message: "Die Verbindung mit der Wortuhr wird wieder hergestellt.",
          flushbarPosition: FlushbarPosition.BOTTOM,
          backgroundColor: Colors.greenAccent,
        ).show(context);
        widget._connectToClock(_onConnectionRestored);
      }
    });
  }

  void _onConnectionRestored() {
    Flushbar(
      duration: Duration(seconds: 5),
      message: "Die Verbindung mit der Wortuhr wurde wieder hergestellt.",
      flushbarPosition: FlushbarPosition.BOTTOM,
      backgroundColor: Colors.green,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    _startBluetoothConnectionListener();
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
                  return ColorPickerDialog(widget._setClockColor);
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
        builder: (
          BuildContext context,
          AsyncSnapshot<List<String>> snapshot,
        ) {
          if (snapshot.hasData) {
            return new AnimatedContainer(
              duration: Duration(seconds: 2),
              curve: Curves.bounceIn,
              child: WordClock(
                snapshot.data,
                currentColor,
              ),
            );
          } else {
            return new Container(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Colors.black,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
