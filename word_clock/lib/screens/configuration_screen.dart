import 'package:flutter/material.dart';

import '../clocks/word_clock/word_clock_rest_commands.dart';
import 'package:wifi/wifi.dart';
import 'dart:async';

class ConfigurationScreen extends StatefulWidget {
  WordClockRestCommands _commands;
  ConfigurationScreen() {
    this._commands = WordClockRestCommands("192.168.4.1");
  }

  @override
  _ConfigurationScreenState createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  String _wifiSSID;
  String _wifiPassword;
  String _clockName;

  Future<String> _getCurrentNetworkSSID() async {
    return "";
  }

  @override
  void initState() {
    super.initState();
    _getCurrentNetworkSSID().then((ssid) {
      setState(() {
        _wifiSSID = ssid;
      });
    });
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
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "WLAN Name",
                ),
                onChanged: (wifiSSID) {
                  _wifiSSID = wifiSSID;
                },
                controller: TextEditingController()..text = _wifiSSID,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "WLAN Passwort",
                ),
                onChanged: (wifiPassword) {
                  _wifiPassword = wifiPassword;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Uhr Name",
                ),
                onChanged: (clockName) {
                  _clockName = clockName;
                },
              ),
            ),
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
          _testConnection().then((state) {
            if (state == WifiState.success) {
              widget._commands
                  .configureClock(_wifiSSID, _wifiPassword, _clockName);
            } else {
              print('Connection error');
            }
          });
        },
      ),
    );
  }

  Future<WifiState> _testConnection() async {
    return Wifi.connection(_wifiSSID, _wifiPassword);
  }
}
