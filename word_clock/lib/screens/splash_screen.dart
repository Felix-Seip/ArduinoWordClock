import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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

  ///Start the timer for the connection timeout.
  ///When the app is first started, it needs to connect the word clock in order
  ///to be used. The default timeout is five seconds. If the connection is not
  ///established within those five seconds, a dialog is shown to inform the
  ///user that one of the two exceptions has occured: 1. Bluetooth is not turned
  ///on 2. The word clock isn't reachable. The dialog differentiates for each
  ///platform. If on iOS, a cupertino styled dialog is shown. If on android,
  ///a material design dialog is shown. If retry is pressed, the timer is
  ///restarted
  void _startConnectionTimer() {
    new Timer(
      Duration(seconds: 5),
      () {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          showCupertinoModalPopup<void>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
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
        } else {
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
        }
      },
    );
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
