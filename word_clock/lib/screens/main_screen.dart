import 'package:flutter/material.dart';

import './select_clock.dart';
import './configuration_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    SelectClock(),
    ConfigurationScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(
              Icons.home,
            ),
            title: new Text('Auswählen'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(
              Icons.add,
            ),
            title: new Text('Konfigurieren'),
          ),
        ],
      ),
    );
  }
}
