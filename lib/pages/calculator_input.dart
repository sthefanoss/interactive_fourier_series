import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_multi_slider/flutter_multi_slider.dart';
import 'package:function_tree/function_tree.dart' as tree;
import 'package:ifs/math/linear_space.dart';
import 'package:ifs/widgets/line_chart.dart';

import '../math/piecewise_function.dart';
import '../strings/constants.dart';
import '../widgets/custom_scaffold.dart';
import '../widgets/piecewise_function_display.dart';

class CalculatorInputPage extends StatefulWidget {
  @override
  _CalculatorInputPageState createState() => _CalculatorInputPageState();
}

class _CalculatorInputPageState extends State<CalculatorInputPage> {
  ///general
  int _tabIndex = 0;

  ///step zero
  final List<TextEditingController> _piecesControllers = [];

  final _formKey = GlobalKey<FormState>();
  PiecewiseFunction _piecewiseFunction = PiecewiseFunction(
    discontinuities: [0],
    expressionsAsString: [
      't',
      'sin(t)',
    ],
  );

  ///step one
  List<tree.SingleVariableFunction> _functions;
  double maxChart = pi;
  double minChart = -pi;
  double maxFunctionWindow;
  double minFunctionWindow;

  List<Point<double>> _chartData;
  double _maxY;

  @override
  void initState() {
    _piecewiseFunction.expressionsAsString.forEach(
      (string) => _piecesControllers.add(
        TextEditingController(text: string),
      ),
    );

    updateDiscontinuitiesAndBoundaries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _language = getLocationCode(context);
    return CustomScaffold(
      appBar: AppBar(
        title: Text(kFunctionInput[_language]),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (int index) {
          if (_tabIndex == index) return;

          //      if (index == 0) {
          setState(() {
            _tabIndex = index;
          });

          if (index == 1) _updateChartData();

          // } else {
          //   _tabIndex = index;
          //
          //   // generateUserInput();
          //   // updateUserInput();
          //   // _updateChartData();
          //
          //   setState(() {});
          // }
        },
        items: [
          BottomNavigationBarItem(
            title: Text('Funcoes'),
            icon: Text(
              'x(t)',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.pink),
            ),
          ),
          BottomNavigationBarItem(
            title: Text('Descontinuidades'),
            icon: Icon(
              Icons.show_chart,
              color: Colors.pink,
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PiecewiseFunctionDisplay(_piecewiseFunction),
              Divider(),
              ..._tabIndex == 0 ? buildFirstPage() : buildSecondPage(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildFirstPage() {
    return [
      for (int index = 0; index < _piecesControllers.length; index++)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _piecesControllers[index],
            onChanged: (String text) {
              try {
                if (text.contains('{')) {
                  _piecesControllers[index].text = text.replaceFirst('{', '');
                  return;
                }
                if (text.contains('}')) {
                  _piecesControllers[index].text = text.replaceFirst('}', '');
                  return;
                }
                final expression = text.toSingleVariableFunction('t');
                setState(() {
                  _piecewiseFunction.expressions[index] = expression;
                  _piecewiseFunction.expressionsAsString[index] = text;
                });
              } catch (e) {
                print(e);
              }
            },
            validator: (String text) {
              try {
                text.toSingleVariableFunction('t');
                return null;
              } catch (e) {
                print(e);
                return 'invalid';
              }
            },
          ),
        ),
      Row(
        children: [
          Expanded(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: _piecesControllers.length < PiecewiseFunction.maxPieces
                  ? () {
                      print(_piecewiseFunction.expressions.length);
                      final String defaultFunction = '0';
                      final expression =
                          defaultFunction.toSingleVariableFunction('t');
                      _piecewiseFunction.expressions.add(expression);
                      _piecewiseFunction.expressionsAsString.add(
                        defaultFunction,
                      );
                      _piecewiseFunction.discontinuities.add(0);
                      setState(() {
                        _piecesControllers
                            .add(TextEditingController(text: defaultFunction));

                        updateDiscontinuitiesAndBoundaries();
                      });
                    }
                  : null,
            ),
          ),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.remove),
              onPressed: _piecesControllers.length > PiecewiseFunction.minPieces
                  ? () {
                      if (_piecewiseFunction.expressions.length > 1)
                        _piecewiseFunction.discontinuities.removeLast();
                      _piecewiseFunction.expressions.removeLast();
                      _piecewiseFunction.expressionsAsString.removeLast();

                      setState(() {
                        _piecesControllers.removeLast();

                        updateDiscontinuitiesAndBoundaries();
                      });
                    }
                  : null,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> buildSecondPage() {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child:

                // LineChart(
                //   LineChartData(
                //     gridData: FlGridData(show: false),
                //     extraLinesData: ExtraLinesData(horizontalLines: [
                //       HorizontalLine(y: 0, strokeWidth: 0.5, color: Colors.black54)
                //     ]),
                //     maxY: _maxY,
                //     minY: -_maxY,
                //     borderData: FlBorderData(show: false),
                //     titlesData: FlTitlesData(show: false
                //         //bottomTitles:
                //         //   SideTitles(showTitles: true, getTitles: _xGenerator),
                //         ),
                //     lineTouchData: LineTouchData(enabled: false),
                //     lineBarsData: [
                //       LineChartBarData(
                //           spots: _chartData,
                //           barWidth: 2,
                //           dotData: FlDotData(show: false),
                //           colors: [Colors.blueGrey]),
                //       LineChartBarData(
                //           spots: _chartData
                //               .where((element) =>
                //                   element.x > minFunctionWindow &&
                //                   element.x < maxFunctionWindow)
                //               .toList(),
                //           barWidth: 5,
                //           dotData: FlDotData(show: false),
                //           colors: [Colors.black]),
                //     ],
                //   ),
                // ),
                LineChart(
              boundaries: ChartBoundaries(
                minX: minChart,
                maxX: maxChart,
                maxY: _maxY,
                minY: -_maxY,
              ),
              input: [
                ChartInput(
                  samples: _chartData,
                  strokeColor: Colors.grey,
                  strokeWidth: 0.2,
                ),
                ChartInput(
                  strokeWidth: 0.2,
                  samples: _chartData
                      .where((sample) =>
                          sample.x < maxFunctionWindow &&
                          sample.x > minFunctionWindow)
                      .toList(),
                ),
              ],
            ),
          ),
          MultiSlider(
            values: [
              minFunctionWindow,
              ..._piecewiseFunction.discontinuities,
              maxFunctionWindow
            ],
            onChanged: (newValues) => setState(() {
              minFunctionWindow = newValues.first;
              _piecewiseFunction.discontinuities = newValues.sublist(
                1,
                newValues.length - 1,
              );
              maxFunctionWindow = newValues.last;
              _updateChartData();
            }),
            max: maxChart,
            min: minChart,
            color: Colors.black,
          ),
        ],
      ),
      FlatButton(
        child: Text('Plotar Serie'),
        onPressed: nextPage,
      )
    ];
  }

  void updateDiscontinuitiesAndBoundaries() {
    int numberOfValues = _piecewiseFunction.discontinuities.length + 2;
    double range = maxChart - minChart;

    List<double> discontinuitiesAndBoundaries = List<double>.generate(
      numberOfValues,
      (index) => range * index / (numberOfValues - 1) + minChart,
    );

    _piecewiseFunction.discontinuities = discontinuitiesAndBoundaries
        .getRange(1, discontinuitiesAndBoundaries.length - 1)
        .toList();

    minFunctionWindow = discontinuitiesAndBoundaries.first;
    maxFunctionWindow = discontinuitiesAndBoundaries.last;
  }

  void _updateChartData([int numberOfPoints = 1024]) {
    final plotData = _piecewiseFunction.callFromLinearSpace(
      LinearSpace(
        start: minChart,
        end: maxChart,
        length: numberOfPoints,
      ),
    );
    _maxY = 1.25 *
        plotData.fold(
            0,
            (previousValue, element) => previousValue.abs() > element.y.abs()
                ? previousValue.abs()
                : element.y.abs());
    _chartData = plotData;
  }

  void nextPage() {
    Navigator.of(context).pushNamed('/calc-result', arguments: [
      [minFunctionWindow, maxFunctionWindow],
      _piecewiseFunction,
    ]);
  }
}
