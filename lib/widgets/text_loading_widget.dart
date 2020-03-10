import 'package:flutter/material.dart';

class TexLoadingWidget extends StatelessWidget {
  TexLoadingWidget({this.text = "Renderizando Texto.\nAguarde, por favor.",this.height = 300});
  final String text;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: height,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Text(text),
          ],
        ),
      ),
    );
  }
}
