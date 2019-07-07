import 'package:flutter/material.dart';
import 'package:wifi/wifi.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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
    _scanDevices();
  }

  Future<Null> _scanDevices() async {
    final String ip = await Wifi.ip;
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final int port = 80;

    final stream = NetworkAnalyzer.discover(subnet, port);
    http.Client client = http.Client();
    stream.listen((NetworkAddress addr) {
      _testConnection(client, addr.ip);
    }, onDone: () {
      if (clocks.length == 0) {
        print("Found ${clocks.length} clocks!");
      } else {
        print("Finished Scanning");
      }
    });

    return null;
  }

  void _testConnection(final http.Client client, final String ip) async {
    try {
      final response = await client.get(Uri.parse('http://$ip/'));

      if (response.statusCode == 200) {
        if (!response.body.startsWith("<")) {
          var data = json.decode(response.body);
          final String clockType = data["variables"]["type"];
          final String roomName = data["variables"]["room_name"];

          if (!clocks.contains(ip)) {
            print(
                'Found a device of type $clockType with ip $ip! Adding it to list of clocks');
            List<Clock> containedClocks = [];
            for (Clock clock in clocks) {
              if (clock.ipAddress.compareTo(ip) == 0) {
                containedClocks.add(clock);
              }
            }

            if (containedClocks.length == 0) {
              _addWordClock(clockType, ip, roomName);
            }
          }
        }
      }
    } on SocketException catch (e) {
      //NOP
    }
  }

  void _addWordClock(
      final String clockType, final String ip, final String roomName) {
    setState(
      () {
        clocks.add(
          Clock(
            clockType,
            ip,
            roomName,
          ),
        );
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
                  return ClockListItem(clocks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
