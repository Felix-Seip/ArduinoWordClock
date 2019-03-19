import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  final Function _writeCharacteristic;

  ColorPickerDialog(this._writeCharacteristic);

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color currentColor;

  void changeColor(Color color) {
    currentColor = color;
    print(currentColor);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0.0),
      contentPadding: const EdgeInsets.all(0.0),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ColorPicker(
              pickerColor: currentColor,
              onColorChanged: changeColor,
              colorPickerWidth: 1000.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: true,
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  child: Text("Vorschau"),
                  onPressed: () {
                    setState(() {});
                    widget._writeCharacteristic(
                      currentColor.red,
                      currentColor.green,
                      currentColor.blue,
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
