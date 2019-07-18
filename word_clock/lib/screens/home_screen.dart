import 'package:flutter/material.dart';
import '../dialogs/color_picker_dialog.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/cupertino.dart';

import 'package:word_clock/widgets/clocks/word_clock/word_clock.dart';
import '../clocks/word_clock/word_clock_rest_commands.dart';
import 'dart:async';
import '../dialogs/clock_configuration_dialog.dart';

///Class to display the main screen of the app.
class HomeScreen extends StatefulWidget {
  final String _ipAddress;
  final String _clockName;

  WordClockRestCommands _wordClockRestCommands;

  HomeScreen(this._ipAddress, this._clockName) {
    this._wordClockRestCommands = WordClockRestCommands(_ipAddress);
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color currentColor = Color.fromARGB(255, 0, 0, 0);

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

  void changeClockConfiguration() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClockConfigurationDialog();
      },
    );
  }

  int _tapCount = 1;
  double _sliderValue = 255;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Clock @ ${widget._clockName}'),
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
            icon: Icon(Icons.edit),
            tooltip: 'Change clock configuration',
            onPressed: () {
              changeClockConfiguration();
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
