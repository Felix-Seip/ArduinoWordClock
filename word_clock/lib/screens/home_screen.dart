import 'package:flutter/material.dart';
import '../dialogs/color_picker_dialog.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';

import 'package:word_clock/widgets/word_clock.dart';
import '../clocks/word_clock/word_clock_rest_commands.dart';
import 'dart:async';

///Class to display the main screen of the app.
class HomeScreen extends StatefulWidget {
  ///Function to set the color of the word clock
  final String _ipAddress;

  WordClockRestCommands _wordClockRestCommands;

  HomeScreen(this._ipAddress) {
    this._wordClockRestCommands = WordClockRestCommands(_ipAddress);
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color currentColor = Color.fromARGB(255, 0, 0, 0);
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
                widget._wordClockRestCommands.setTime(TimeOfDay(
                    hour: newDateTime.hour, minute: newDateTime.minute));
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
        widget._wordClockRestCommands.setTime(time);
      }
    }
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
                  return ColorPickerDialog(
                      widget._wordClockRestCommands.setLEDColor);
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
            return Column(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_tapCount == 1) {
                        Timer(Duration(seconds: 10), () {
                          if (!(_tapCount >= 10)) {
                            _tapCount = 1;
                          }
                        });
                      }
                      _tapCount++;
                      if (_tapCount == 10) {
                        print("show freya");
                        widget._wordClockRestCommands.showFreya();
                        _tapCount = 1;
                      }
                    },
                    child: WordClock(
                      snapshot.data,
                      currentColor,
                      true,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 100, left: 40, right: 40),
                  child: Column(
                    children: <Widget>[
                      Slider(
                        activeColor: Colors.indigoAccent,
                        min: 10.0,
                        max: 255.0,
                        label: "Set brightness",
                        onChanged: (newValue) {
                          setState(() {
                            _sliderValue = newValue;
                          });
                        },
                        onChangeEnd: (brightness) {
                          widget._wordClockRestCommands
                              .changeBrightness(brightness);
                        },
                        value: _sliderValue,
                      ),
                    ],
                  ),
                ),
              ],
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
