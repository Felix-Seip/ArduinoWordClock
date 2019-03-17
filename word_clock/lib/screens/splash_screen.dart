import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

class SplashScreen extends StatefulWidget {
  final Function _retryConnection;

  SplashScreen(this._retryConnection);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(
            () {
              _visible = !_visible;
            },
          ),
    );
    _startConnectionTimer();
  }

  void _startConnectionTimer() {
    new Timer(Duration(seconds: 5), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Verbindung Fehlgeschlagen",
            ),
            content: Text(
              "Bitte stellen Sie sicher das die Wortuhr an ist" +
                  "und dass Sie die Bluetooth Funktion an Ihrem Handy angeschaltet haben",
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Erneut Versuchen"),
                onPressed: () {
                  widget._retryConnection();
                  _startConnectionTimer();
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Abbrechen"),
                onPressed: () {
                  exit(0);
                },
              )
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 10, 9, 8),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 3000),
              child: Image.asset(
                'assets/logo.png',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(30),
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
