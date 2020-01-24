import 'package:flutter/material.dart';

import '../clocks/word_clock/word_clock_rest_commands.dart';
import '../widgets/configuration_item.dart';

class ConfigurationScreen extends StatefulWidget {
  final WordClockRestCommands _commands = WordClockRestCommands("192.168.4.1");

  @override
  _ConfigurationScreenState createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  String _wifiSSID;
  String _wifiPassword;
  String _clockName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uhrkonfiguration'),
        backgroundColor: Color.fromARGB(255, 10, 9, 8),
      ),
      backgroundColor: Color.fromARGB(255, 242, 244, 243),
      body: Padding(
        padding: EdgeInsets.all(50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ConfigurationItem("WLAN Name", (String text) {
              _wifiSSID = text;
            }, EdgeInsets.all(10)),
            ConfigurationItem("WLAN Passwort", (String text) {
              _wifiPassword = text;
            }, EdgeInsets.all(10)),
            ConfigurationItem("Uhr Name", (String text) {
              _clockName = text;
            }, EdgeInsets.all(10)),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "Um eine neue Uhr zu konfigurieren, stellen Sie bitte sicher dass Sie mit dem WLAN von der Uhr verbunden sind. Nur so ist eine Konfiguration der Uhr möglich.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(100, 0, 0, 0),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          widget._commands.configureClock(_wifiSSID, _wifiPassword, _clockName);
        },
      ),
    );
  }
}
