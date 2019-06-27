import 'package:flutter/material.dart';
import 'package:wifi/wifi.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../model/clock.dart';
import '../widgets/clock_list_item.dart';

class SelectClock extends StatefulWidget {
  @override
  _SelectClockState createState() => _SelectClockState();
}

class _SelectClockState extends State<SelectClock> {
  List<Clock> clocks = [];

  @override
  void initState() {
    super.initState();

    _scanDevices();

    //For debugging purposes only
    //_addWordClock("word-clock", "192.168.4.1", "Wohnzimmer");
    //_addWordClock("word-clock", "192.168.4.2", "Schlafzimmer");
  }

  Future<Null> _scanDevices() async {
    final String ip = await Wifi.ip;
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final int port = 80;

    final stream = NetworkAnalyzer.discover(subnet, port);
    http.Client client = http.Client();
    stream.listen((NetworkAddress addr) {
      _testConnection(client, addr.ip);
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
    setState(() {
      clocks.add(Clock(clockType, ip, roomName));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Clock'),
        backgroundColor: Color.fromARGB(255, 10, 9, 8),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Change clock time',
            onPressed: () {
              _scanDevices();
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 242, 244, 243),
      body: RefreshIndicator(
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
