import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

abstract class ClockRestCommands {
  String ip;
  http.Client client;

  void sendClockCommand(final String restPath, final String param) async {
    try {
      final response =
          await client.get(Uri.parse('http://$ip/$restPath?param=$param'));

      switch (response.statusCode) {
        case 200:
          if (!response.body.startsWith("<")) {
            json.decode(response.body);
          }
          break;
        case 404:
          break;
        default:
      }
    } on SocketException catch (e) {
      //NOP
    }
  }

  void changeBrightness(
    final double brightness,
  ) {
    String brightnessCommand = "$brightness";
    sendClockCommand("clockbrightness", brightnessCommand);
  }

  void setTime(
    final TimeOfDay time,
  ) {
    String timeCommand = "${time.hour},${time.minute}";
    sendClockCommand("clocktime", timeCommand);
  }

  void setLEDColor(
    final int r,
    final int g,
    final int b,
  ) {
    String colorCommand = "$r,$g,$b";
    sendClockCommand("clockcolor", colorCommand);
  }

  void configureClock(
    final String wifiSSID,
    final String wifiPassword,
    final String clockRoom,
  ) {
    String configureCommand =
        "ssid=$wifiSSID,password=$wifiPassword,room-name=$clockRoom";
    sendClockCommand("clockconfiguration", configureCommand);
  }

  void changeClockName(
    final String clockName,
  ) {
    String clockNameCommand = "$clockName";
    sendClockCommand("clockname", clockNameCommand);
  }
}
