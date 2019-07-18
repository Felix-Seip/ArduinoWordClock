import 'package:flutter/material.dart';

enum ElementType {
  MINUTE,
  HOUR,
}

class ClockElement extends StatefulWidget {
  String _text = "";
  Color _color;
  List<int> _numericValues = [];
  ElementType _elementType;
  _ClockElementState _state;

  ClockElement(this._text, this._color,
      [this._numericValues, this._elementType]);

  int getNumericValuesAtIndex(int index) {
    return _numericValues[index];
  }

  ElementType getClockElementType() {
    return _elementType;
  }

  void setColor(final Color color) {
    _color = color;
    if (_state != null) {
      _state.setColor();
    }
  }

  String getText() {
    return _text;
  }

  @override
  _ClockElementState createState() {
    _state = _ClockElementState();
    return _state;
  }
}

class _ClockElementState extends State<ClockElement> {
  void setColor() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget._color,
      ),
      child: Container(
        alignment: Alignment.center,
        child: Text(
          widget._text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
