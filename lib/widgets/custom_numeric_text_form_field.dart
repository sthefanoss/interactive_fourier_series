import 'package:flutter/material.dart';


class CustomNumericTextFormField extends StatelessWidget {
  CustomNumericTextFormField(
      {this.onSaved, this.controller, this.validator, this.labelText});
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final String labelText;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        onSaved: onSaved,
        decoration:
        InputDecoration(labelText: labelText, border: OutlineInputBorder()),
      ),
    );
  }
}
