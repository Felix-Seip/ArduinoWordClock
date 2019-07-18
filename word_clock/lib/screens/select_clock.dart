import 'package:flutter/material.dart';
import '../util/device_scanner.dart';
import 'dart:async';

import '../model/clock.dart';
import '../widgets/clock_list/clock_list.dart';

class SelectClock extends StatefulWidget {
  @override
  _SelectClockState createState() => _SelectClockState();
}

class _SelectClockState extends State<SelectClock> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List<Clock> _clocks = [];

  @override
  void initState() {
    super.initState();
    //_clocks.add(Clock("word-clock", "192.168.2.147", "Bedroom"));
  }

  Future<Null> _scanDevices() {
    return DeviceScanner.scanDevicesInLocalNetwork().then(
      (clocks) {
        setState(() {
          _clocks.addAll(clocks);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('99Crafts Uhren'),
        backgroundColor: Color.fromARGB(255, 10, 9, 8),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh list of clocks',
            onPressed: () {
              _refreshIndicatorKey.currentState.show();
              _scanDevices();
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 242, 244, 243),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _scanDevices,
        child: _clocks.length == 0
            ? Padding(
                padding: EdgeInsets.all(50),
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Text(
                        "Es wurden keine 99 Crafts Uhren gefunden. Bitte stellen Sie sicher dass Sie mit einem WLAN Netzwerk verbunden sind und dass sich 99 Crafts Uhren in dem Netzwerk befinden.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(100, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
            : ClockList(_clocks),
      ),
    );
  }
}
