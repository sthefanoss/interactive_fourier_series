import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget floatingActionButton;
  final Widget body;
  final BottomNavigationBar bottomNavigationBar;

  const CustomScaffold({
    this.appBar,
    this.floatingActionButton,
    this.body,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.withOpacity(0.2),
      primary: false,
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: BoxConstraints.loose(Size.fromWidth(580)),
          child: Scaffold(
            primary: true,
            backgroundColor: Colors.white,
            appBar: appBar,
            floatingActionButton: floatingActionButton,
            body: body,
            bottomNavigationBar: bottomNavigationBar,
          ),
        ),
      ),
    );
  }
}
