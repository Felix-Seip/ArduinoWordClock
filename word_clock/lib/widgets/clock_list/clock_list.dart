import 'package:flutter/material.dart';

import './clock_list_item.dart';
import '../../model/clock.dart';

class ClockList extends StatelessWidget {
  final List<Clock> _clocks;
  ClockList(this._clocks);

  @override
  Widget build(BuildContext context) {
    return Flex(
      crossAxisAlignment: CrossAxisAlignment.start,
      direction: Axis.vertical,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _clocks.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return ClockListItem(
                _clocks[index],
              );
            },
          ),
        ),
      ],
    );
  }
}
