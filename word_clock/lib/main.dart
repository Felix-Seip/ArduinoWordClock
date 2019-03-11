import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:after_layout/after_layout.dart';

import 'dart:async';

import './screens/splash_screen.dart';
import './screens/home_screen.dart';

enum ClockMode { Rainbow, Breathing }
String _deviceName = "DSD TECH";

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> with AfterLayoutMixin<MyApp> {
  FlutterBlue _flutterBlue;
  BluetoothDevice _connectedDevice;
  BluetoothDeviceState _deviceState = BluetoothDeviceState.disconnected;
  StreamSubscription _deviceStateSubscription;
  List<BluetoothService> _services = new List();

  var scanSubscription;
  var deviceConnection;

  static const int timeout = 3;

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    _scanDevices();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 94, 80, 63),
        accentColor: Color.fromARGB(255, 94, 80, 63),
      ),
      home: Scaffold(
        body: HomeScreen(_connectedDevice, _connect, _disconnect),
      ),
    );
  }

  void _scanDevices() async {
    _flutterBlue = FlutterBlue.instance;
    print("Scanning for devices");
    scanSubscription = _flutterBlue.scan().listen(
      (scanResult) {
        String deviceName = scanResult.device.name.toLowerCase();
        print("Found device with name " + deviceName);
        if (deviceName.compareTo(_deviceName.toLowerCase()) == 0) {
          _connect(scanResult.device);
        }
      },
    );
  }

  void _connect(BluetoothDevice device) async {
    print("Cancelling scan subscription...");
    scanSubscription.cancel();

    print("Connecting to device " + device.name);
    //Connect to the device
    deviceConnection = _flutterBlue
        .connect(
          device,
          timeout: const Duration(seconds: 4),
        )
        .listen(
          null,
          onDone: _disconnect,
        );

    // Update the connection state immediately
    device.state.then(
      (state) {
        new Future.delayed(const Duration(seconds: timeout), () {
          setState(
            () {
              _connectedDevice = device;
              _deviceState = state;
            },
          );
        });
      },
    );

    // Subscribe to connection changes
    _deviceStateSubscription = device.onStateChanged().listen(
      (state) {
        setState(
          () {
            _deviceState = state;
          },
        );

        if (state == BluetoothDeviceState.connected) {
          device.discoverServices().then(
            (services) {
              setState(
                () {
                  _services = services;
                },
              );
            },
          );
        }
      },
    );
  }

  startTimeout([int milliseconds]) {}

  void handleTimeout() {}

  void _showConnectionError() {
    throw new UnimplementedError();
  }

  void _disconnect() {
    deviceConnection.cancel();
    _connectedDevice = null;
    _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;
  }

  void _writeCharacteristic() async {
    throw new UnimplementedError();
    //await _connectedDevice.writeCharacteristic(c, [0x12, 0x34], type: CharacteristicWriteType.withResponse);
  }

  void _writeDescriptor(BluetoothDescriptor d) async {
    throw new UnimplementedError();
    //await _connectedDevice.writeDescriptor(d, [0x12, 0x34]);
  }

  void setTime(final String message) {
    throw new UnimplementedError();
    //_writeCharacteristic(null);
  }

  void setClockMode(final ClockMode mode) {
    throw new UnimplementedError();
    //_writeCharacteristic(null);
  }

  void setLEDColor(final int r, final int g, final int b) {}
  bool get isConnected => (_connectedDevice != null);
}
