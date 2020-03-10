import 'package:flutter/material.dart';

class RadioText<T> extends StatelessWidget {
  RadioText(
      {@required this.value,
        @required this.onChanged,
        @required this.text,
        @required this.groupValue});
  final String text;
  final T value, groupValue;
  final Function onChanged;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Radio<T>(value: value, onChanged: onChanged, groupValue: groupValue),
        Text(text)
      ],
    );
  }
}
