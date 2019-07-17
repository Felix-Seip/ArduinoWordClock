import 'package:flutter/material.dart';
import '../util/device_scanner.dart';
import 'dart:async';

import '../model/clock.dart';
import '../widgets/clock_list_item.dart';
import './configuration_screen.dart';

class SelectClock extends StatefulWidget {
  @override
  _SelectClockState createState() => _SelectClockState();
}

class _SelectClockState extends State<SelectClock> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List<Clock> clocks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    //clocks.add(Clock("word-clock", "192.168.2.147", "Bedroom"));
  }

  Future<Null> _scanDevices() {
    return DeviceScanner.scanDevicesInLocalNetwork().then(
      (clocks) {
        setState(() {
          clocks = clocks;
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
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Configure a new clock',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfigurationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 242, 244, 243),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _scanDevices,
        child: Flex(
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: clocks.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return ClockListItem(
                    clocks[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
