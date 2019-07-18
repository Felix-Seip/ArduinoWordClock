import 'package:flutter/material.dart';

class ClockConfigurationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        height: 220.0,
        width: 300.0,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                color: Color.fromARGB(255, 10, 9, 8),
              ),
              child: Padding(
                child: Text(
                  "Edit Clock Configuration",
                  style: TextStyle(
                    color: Color.fromARGB(255, 242, 244, 243),
                    fontSize: 18,
                  ),
                ),
                padding: EdgeInsets.all(22),
              ),
            ),
            Expanded(
              child: Padding(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Uhr Name",
                  ),
                ),
                padding: EdgeInsets.all(30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
