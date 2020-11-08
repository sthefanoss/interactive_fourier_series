import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ifs/pages/function_output_page.dart';
import 'package:ifs/pages/functions_catalog_page.dart';
import 'package:ifs/pages/home_page.dart';
import 'package:ifs/pages/theory_page.dart';

import './pages/function_input_page.dart';
import 'pages/about_page.dart';

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
        '/theory': (ctx) => TheoryPage(),
        '/func-cat': (ctx) => FunctionsCatalogPage(),
        '/func-input': (ctx) => FunctionInputPage(),
        '/func-output': (ctx) => FunctionOutputPage(),
        '/about': (ctx) => AboutPage(),
      },
    );
  }
}
