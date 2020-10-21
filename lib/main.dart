import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ifs/pages/calculator_result.dart';
import 'package:ifs/pages/function_catalog.dart';
import 'package:ifs/pages/home.dart';

import './pages/calculator_input.dart';
import 'pages/info.dart';

void main() {
  runApp(FlutterFourierSeries());
}

class FlutterFourierSeries extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('pt'), // Hebrew
      ],
      title: 'Fourier App',
      theme: ThemeData(
          primaryColor: Colors.blueGrey,
          accentColor: Colors.black,
          cursorColor: Colors.grey,
          focusColor: Colors.grey),
      routes: {
        '/': (ctx) => HomePage(),
        '/calc-input': (ctx) => CalculatorInputPage(),
        '/func-cat': (ctx) => FunctionCatalogPage(),
        '/calc-result': (ctx) => CalculatorResultPage(),
        '/info': (ctx) => InfoPage(),
      },
    );
  }
}
