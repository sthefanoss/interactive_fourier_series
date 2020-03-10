import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import './pages/calculator.dart';

void main() => runApp(FlutterFourierSeries());

class FlutterFourierSeries extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('pt'),
        // ... other locales the app supports
      ],
      theme: ThemeData(),
      home: CalculatorPage(),
    );
  }
}
