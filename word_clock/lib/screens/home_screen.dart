import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../dialogs/color_picker_dialog.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';

import 'package:flushbar/flushbar.dart';

import 'package:word_clock/widgets/word_clock.dart';
import 'dart:async';

///Class to display the main screen of the app.
class HomeScreen extends StatefulWidget {
  ///The bluetooth object that is used to manage listeners, devices, etc.
  final FlutterBlue _flutterBlue;

  ///The word clock that the application is connected to
  final BluetoothDevice _wordClock;

  ///Function to connect to the word clock
  final Function _connectToClock;

  ///Function to disconnect from the word clock
  final Function _disconnectFromClock;

  ///Function to set the color of the word clock
  final Function _setClockColor;

  ///Function to set the time of the word clock
  final Function _setClockTime;

  ///Function to show the word 'freya'
  final Function _showFreya;

  ///Function to change the brightness of the word clock
  final Function _changeBrightness;

  HomeScreen(
    this._flutterBlue,
    this._wordClock,
    this._connectToClock,
    this._disconnectFromClock,
    this._setClockColor,
    this._setClockTime,
    this._showFreya,
    this._changeBrightness,
  );

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color currentColor = Color.fromARGB(255, 0, 0, 0);
  List<String> _clockLetters;
  TimeOfDay _selectedTime = TimeOfDay.now();

  ///Loads the clock letters the file "assets/clock_text.txt"
  ///Load the clock letters to be displayed on the main screen.
  ///These letters are used as a preview for the actual word clock.
  Future<List<String>> _loadClockLetters() {
    return rootBundle
        .loadString('assets/clock_text.txt')
        .then((String contents) {
      return contents.split(" ");
    });
  }

  /*
   * Build the 
   */
  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  ///Build and show the time picker dialog. The picker differentiates between
  ///the two platforms. If on iOS, it uses a cupertino styled time picker
  ///dialog. If on android, a material themed time picker dialog is shown.
  Future<void> selectTime(BuildContext context) async {
    //If the platform is iOS
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) {
          return _buildBottomPicker(
            CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: DateTime.now(),
              onDateTimeChanged: (DateTime newDateTime) {
                //_selectedTime = newDateTime.to;
                widget._setClockTime(newDateTime);
              },
            ),
          );
        },
      );
    } else {
      //If on android
      final TimeOfDay time = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
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
        _selectedTime = time;
        widget._setClockTime(time);
      }
    }
  }

  ///Start the bluetooth connection listener. This serves to inform the user
  ///when the bluetooth connection has changed. If bluetooth has been turned
  ///off on the users device, a flushbar appears at the bottom of the screen
  ///with a red background, and a text informing the user that bluetooth has
  ///been turned off. If bluetooth is turned on again, the background color is
  ///green and informs the user, once again, that a connection to the word clock
  ///is being established
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

  ///Informs the user that the connection has been reestablished. If the
  ///connection to the word clock has been lost, the app will try to reconnect.
  ///Once the connection has been established, it shows a flushbar informing
  ///the user that the connection has been reestablished
  void _onConnectionRestored() {
    Flushbar(
      duration: Duration(seconds: 5),
      message: "Die Verbindung mit der Wortuhr wurde wieder hergestellt.",
      flushbarPosition: FlushbarPosition.BOTTOM,
      backgroundColor: Colors.green,
    ).show(context);
  }

  int _tapCount = 1;
  double _sliderValue = 255;

  @override
  Widget build(BuildContext context) {
    //_startBluetoothConnectionListener();
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
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            return AnimatedContainer(
                duration: Duration(seconds: 2),
                curve: Curves.bounceIn,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        _tapCount++;
                        Timer(
                          Duration(milliseconds: 500),
                          () {
                            _tapCount = 1;
                          },
                        );

                        if (_tapCount == 10) {
                          widget._showFreya();
                          _tapCount = 1;
                        }
                      },
                      child: WordClock(
                        snapshot.data,
                        currentColor,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        activeColor: Colors.indigoAccent,
                        min: 10.0,
                        max: 255.0,
                        onChanged: (newValue) {
                          setState(() {
                            _sliderValue = newValue;
                          });
                        },
                        onChangeEnd: (brightness) {
                          widget._changeBrightness(brightness);
                        },
                        value: _sliderValue,
                      ),
                    ),
                  ],
                ));
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
