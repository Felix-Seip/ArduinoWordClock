import 'package:flutter/material.dart';
import '../../model/clock.dart';
import '../../screens/home_screen.dart';

class ClockListItem extends StatelessWidget {
  final Clock _clock;

  ClockListItem(this._clock);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(40),
      child: ListTile(
        title: Text(
            "${_clock.clockType.compareTo("word-clock") == 0 ? "Word Clock" : "Random Clock"} @ ${_clock.roomName}"),
        subtitle: Image.asset(
          "assets/word-clock.png",
          scale: 1.5,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(_clock.ipAddress, _clock.roomName),
            ),
          );
        },
      ),
    );
  }
}
