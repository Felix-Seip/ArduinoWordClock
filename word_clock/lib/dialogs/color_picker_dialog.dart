import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';

class ColorPickerDialog extends StatefulWidget {
  final Function _changeClockColor;

  ColorPickerDialog(this._changeClockColor);

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color currentColor = Colors.black;

  void changeColor(Color color) {
    widget._changeClockColor(
      color.red,
      color.green,
      color.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        child: SingleChildScrollView(
          //physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(25),
          child: BlockPicker(
            //availableColors: [Colors.red, Colors.black, Colors.blue],
            pickerColor: currentColor,
            onColorChanged: changeColor,
            availableColors: [
              Color.fromARGB(
                255,
                235,
                52,
                35,
              ),
              Color.fromARGB(
                255,
                238,
                98,
                42,
              ),
              Color.fromARGB(
                255,
                244,
                177,
                62,
              ),
              Color.fromARGB(
                255,
                254,
                252,
                83,
              ),
              Color.fromARGB(
                255,
                186,
                250,
                80,
              ),
              Color.fromARGB(
                255,
                117,
                249,
                76,
              ),
              Color.fromARGB(
                255,
                116,
                249,
                182,
              ),
              Color.fromARGB(
                255,
                82,
                249,
                182,
              ),
              Color.fromARGB(
                255,
                0,
                41,
                245,
              ),
              Color.fromARGB(
                255,
                228,
                64,
                247,
              ),
              Color.fromARGB(
                255,
                235,
                56,
                153,
              ),
              Color.fromARGB(
                255,
                230,
                230,
                230,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
