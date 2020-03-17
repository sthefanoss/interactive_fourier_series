import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../strings/constants.dart';
class TexLoadingWidget extends StatelessWidget {
  TexLoadingWidget({this.text,this.height = 300});
  final String text;
  final double height;
  @override
  Widget build(BuildContext context) {
    final _language = getLocationCode(context);
    return Center(
      child: Container(
        height: height,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CupertinoActivityIndicator(),
            Text(text?? kWaitingForRenderingText[_language]),
          ],
        ),
      ),
    );
  }
}
