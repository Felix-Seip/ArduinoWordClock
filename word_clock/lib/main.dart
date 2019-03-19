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

  bool _isPastSplashScreen = false;

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
        body: _connectedDevice == null && !_isPastSplashScreen
            ? SplashScreen(_scanDevices)
            : HomeScreen(
                _flutterBlue,
                _connectedDevice,
                _scanDevices,
                _disconnect,
                _setLEDColor,
                _setTime,
              ),
      ),
    );
  }

  void _scanDevices([Function _onDeviceConnectionRestored]) async {
    _flutterBlue = FlutterBlue.instance;
    if (_onDeviceConnectionRestored != null) {
      _isPastSplashScreen = true;
    }
    print("Scanning for devices");

    try {
      scanSubscription = _flutterBlue.scan().listen(
        (scanResult) {
          String deviceName = scanResult.device.name.toLowerCase();
          print("Found device with name " + deviceName);
          if (deviceName.compareTo(_deviceName.toLowerCase()) == 0) {
            _connect(scanResult.device, _onDeviceConnectionRestored);
          }
        },
      );
    } catch (ex) {
      print(ex);
    }
  }

  void _connect(BluetoothDevice device,
      [Function _onDeviceConnectionRestored]) async {
    print("Cancelling scan subscription...");
    scanSubscription.cancel();

    print("Connecting to device " + device.name);

    _disconnect();

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
          if (_onDeviceConnectionRestored != null) {
            device.discoverServices().then(
              (services) {
                _services = services;
                _onDeviceConnectionRestored();
              },
            );
          } else {
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
        }
      },
    );
  }

  void _disconnect() {
    deviceConnection?.cancel();
    _connectedDevice = null;
    _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;
    _services = [];
    print("Device connection lost");
  }

  void _writeCharacteristic(List<int> data) async {
    for (BluetoothService service in _services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        //String bla = characteristic.uuid.toString();
        print("Characteristic UUID: " + characteristic.uuid.toString());
        if (characteristic.uuid.toString().toLowerCase().contains(
              "FFE1".toLowerCase(),
            )) {
          try {
            await _connectedDevice.writeCharacteristic(
              characteristic,
              data,
              type: CharacteristicWriteType.withoutResponse,
            );
            break;
          } catch (ex) {
            print(
              "Something went wrong while writing to the bluetooth device: " +
                  ex.toString(),
            );
          }
        }
      }
    }
  }

  void _setTime(final TimeOfDay time) {
    String timeCommand = "setTime(${time.hour},${time.minute})";
    _writeCharacteristic(timeCommand.codeUnits);
  }

  void _setLEDColor(final int r, final int g, final int b) {
    String colorCommand = "setColor($r,$g,$b)";
    _writeCharacteristic(colorCommand.codeUnits);
  }

  bool get isConnected => (_connectedDevice != null);
}
