import 'package:flutter/material.dart';

class ConfigurationItem extends StatelessWidget {
  final String _title;
  final String _initialValue;
  final EdgeInsets _edgeInsets;
  final Function _onTextChanged;

  ///_title: The title of the configuration item
  ///_edgeInsets: The amount of padding to be used. The default is EdgeInsets.only(top: 10, bottom: 10)
  ///_onTextChanged: Function to be called when the input field is changed
  ConfigurationItem(this._title, this._onTextChanged,
      [this._edgeInsets, this._initialValue]);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _edgeInsets,
      child: TextField(
        decoration: InputDecoration(
          hintText: _title,
        ),
        onChanged: (wifiPassword) {
          _onTextChanged(wifiPassword);
        },
        controller: TextEditingController()..text = _initialValue,
      ),
    );
  }
}
