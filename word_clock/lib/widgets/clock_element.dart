import 'package:flutter/material.dart';

enum ElementType { MINUTE, HOUR }

class ClockElement extends StatefulWidget {
  String _text = "";
  Color _color;
  List<int> _numericValues = [];
  ElementType _elementType;
  int _rangeFrom;
  int _rangeTo;

  ClockElement(this._text, this._color, this._rangeFrom, this._rangeTo,
      this._numericValues, this._elementType);

  int getNumericValuesAtIndex(int index) {
    return _numericValues[index];
  }

  ElementType getClockElementType() {
    return _elementType;
  }

  @override
  _ClockElementState createState() => _ClockElementState();
}

class _ClockElementState extends State<ClockElement> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget._text,
      style: TextStyle(color: widget._color),
    );
  }
}
