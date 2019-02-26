import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Clock'),
        actions: null,
      ),
      backgroundColor: Color.fromARGB(255, 242, 244, 243),
      body: Center(),
    );
  }
}
