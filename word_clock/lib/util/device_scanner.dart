import 'package:wifi/wifi.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import '../model/clock.dart';

class DeviceScanner {
  static Future<List<Clock>> scanDevicesInLocalNetwork() async {
    List<Clock> clocks = [];
    final String ip = await Wifi.ip;
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final int port = 80;

    final stream = NetworkAnalyzer.discover(subnet, port);
    stream.listen((NetworkAddress addr) {
      Future<Clock> clock = _testConnection(addr.ip);
      clock.then((clockValue) {
        if (!clocks.contains(ip)) {
          if (null != clockValue) {
            print(
                'Found a device of type ${clockValue.clockType} with ip $ip! Adding it to list of clocks');
            List<Clock> containedClocks = [];
            for (Clock clock in clocks) {
              if (clock.ipAddress.compareTo(ip) == 0) {
                containedClocks.add(clock);
              }
            }

            if (containedClocks.length == 0) {
              clocks.add(clockValue);
            }
          }
        }
      });
    }, onDone: () {
      print("Finished Scanning");
      print("Found ${clocks.length} clocks!");
      return clocks;
    });

    return clocks;
  }

  static Future<Clock> _testConnection(final String ip) async {
    http.Client client = http.Client();
    try {
      if (ip.endsWith(".2") || ip.endsWith(".1")) {
        return null;
      }
      final response = await client.get(Uri.parse('http://192.168.2.147/'));

      if (response.statusCode == 200) {
        if (!response.body.startsWith("<")) {
          var data = json.decode(response.body);
          final String clockType = data["variables"]["type"];
          final String roomName = data["variables"]["room_name"];
          return Clock(clockType, ip, roomName);
        }
      }
    } on SocketException catch (e) {
      //NOP
    } on TimeoutException catch (e) {
      //NOP
    }
    client.close();
    return null;
  }
}
