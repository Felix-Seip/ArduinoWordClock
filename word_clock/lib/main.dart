import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';

import 'dart:async';

import './screens/splash_screen.dart';
import './screens/home_screen.dart';

enum ClockMode { Rainbow, Breathing }
String _deviceName = "WordClock";

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  FlutterBlue _flutterBlue;
  BluetoothDevice _connectedDevice;
  BluetoothDeviceState _deviceState = BluetoothDeviceState.disconnected;
  StreamSubscription _deviceStateSubscription;
  List<BluetoothService> _services = new List();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      //Scan for clock
      (_) => {},
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Color.fromARGB(255, 34, 116, 165)),
      home: Scaffold(
        body: _connectedDevice == null ? SplashScreen() : HomeScreen(),
      ),
    );
  }

  void _scanDevices() {
    _flutterBlue.scan().listen((scanResult) {
      String deviceName = scanResult.device.name.toLowerCase();
      if (deviceName.compareTo(_deviceName.toLowerCase()) == 1) {
        _connect(scanResult.device);
      }
    });
  }

  void _connect(BluetoothDevice device) async {
    //Connect to the device
    _flutterBlue.connect(device, timeout: const Duration(seconds: 4)).listen(
          //onError: _showConnectionError,
          null,
          onDone: _disconnect,
        );

    // Update the connection state immediately
    device.state.then((state) {
      setState(() {
        //Only show move on to the HomeScreen when the device has been connected successfully
        if (state == BluetoothDeviceState.connected) {
          _connectedDevice = device;
        } else if (state == BluetoothDeviceState.disconnected) {
          //Show "device disconnected" message
        }
        _deviceState = state;
      });
    });

    // Subscribe to connection changes
    _deviceStateSubscription = device.onStateChanged().listen((state) {
      setState(() {
        _deviceState = state;
      });

      if (state == BluetoothDeviceState.connected) {
        device.discoverServices().then((services) {
          setState(() {
            _services = services;
          });
        });
      }
    });
  }

  void _showConnectionError() {
    throw new UnimplementedError();
  }

  void _disconnect() {
    _connectedDevice = null;
    _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;
  }

  void _writeCharacteristic(BluetoothCharacteristic c) async {
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
