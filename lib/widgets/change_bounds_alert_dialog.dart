import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import '../strings/constants.dart';
import 'custom_numeric_text_form_field.dart';

class ChangeBoundsAlertDialog extends StatefulWidget {
  const ChangeBoundsAlertDialog({this.formKey, this.controllers});
  final List<TextEditingController> controllers;
  final GlobalKey<FormState> formKey;
  @override
  _ChangeBoundsAlertDialogState createState() =>
      _ChangeBoundsAlertDialogState();
}

class _ChangeBoundsAlertDialogState extends State<ChangeBoundsAlertDialog> {
  String _language;
  double start, end;
  bool error = false, _init = true;

  @override
  void didChangeDependencies() {
    if (_init) {
      _language = getLocationCode(context);
      setState(() {
        _init = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(kChangeBoundsText[_language]),
      contentPadding: EdgeInsets.all(20),
      elevation: 5,
      actions: <Widget>[
        FlatButton(
          textColor: Colors.black,
          child: Text(kBackText[_language]),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          textColor: Colors.black,
          child: Text(kDefault[_language]),
          onPressed: error
              ? null
              : () {
                  setState(() {
                    widget.controllers[0].text = '-pi/2';
                    widget.controllers[1].text = 'pi/2';
                  });
                },
        ),
        FlatButton(
          textColor: Colors.black,
          child: Text(kAccept[_language]),
          onPressed: error
              ? () {
                  setState(() {
                    error = false;
                  });
                }
              : () {
                  if (!widget.formKey.currentState.validate()) return;
                  if (start >= end) {
                    setState(() {
                      error = true;
                    });
                    return;
                  } else {
                    Navigator.of(context)
                        .pop<RangeValues>(RangeValues(start, end));
                  }
                },
        ),
      ],
      content: Form(
        key: widget.formKey,
        child: error
            ? Text(
                kChangeBoundsErrorText[_language],
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              )
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    CustomNumericTextFormField(
                      labelText: kStartText[_language],
                      controller: widget.controllers[0],
                      validator: (value) {
                        try {
                          start = value.interpret().toDouble();
                          return null;
                        } catch (e) {
                          return kInvalidExpressionText[_language];
                        }
                      },
                    ),
                    CustomNumericTextFormField(
                      labelText: kEndText[_language],
                      controller: widget.controllers[1],
                      validator: (value) {
                        try {
                          end = value.interpret().toDouble();
                          return null;
                        } catch (e) {
                          return kInvalidExpressionText[_language];
                        }
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
