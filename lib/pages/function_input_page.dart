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

class FunctionInputPage extends StatefulWidget {
  @override
  _FunctionInputPageState createState() => _FunctionInputPageState();
}

class _FunctionInputPageState extends State<FunctionInputPage> {
  ///general
  int _tabIndex = 0;
  bool _hasError = false;

  ///step zero
  final List<TextEditingController> _piecesControllers = [];

  final _formKey = GlobalKey<FormState>();
  PiecewiseFunction _piecewiseFunction = PiecewiseFunction(
    discontinuities: [0],
    expressionsAsString: [
      '0',
      'sqrt(t)',
    ],
  );

  ///step one
  List<tree.SingleVariableFunction> _functions;
  double maxChart = pi;
  double minChart = -pi;
  double maxFunctionWindow;
  double minFunctionWindow;

  List<Point<double>> _chartData = [];
  double _maxY = 1.25;

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
        title: Text(kFunctionInputTitle[_language]),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (int index) {
          if (_tabIndex == index) return;

          setState(() => _tabIndex = index);

          if (index == 1) _updateChartData();
        },
        items: [
          BottomNavigationBarItem(
            label: kExpressionsText[_language],
            icon: Container(),
          ),
          BottomNavigationBarItem(
            label: kPointsAndWindowText[_language],
            icon: Container(),
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
      floatingActionButton: _tabIndex == 1
          ? FloatingActionButton(
              onPressed: _hasError ? null : nextPage,
              child: Icon(
                Icons.navigate_next_sharp,
              ),
              backgroundColor: _hasError ? Theme.of(context).errorColor : null,
            )
          : null,
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
    final _language = getLocationCode(context);
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: LineChart(
              boundaries: ChartBoundaries(
                minX: minChart,
                maxX: maxChart,
                maxY: _maxY,
                minY: -_maxY,
              ),
              input: [
                ChartInput(
                  samples: _chartData,
                  strokeColor: Colors.black.withOpacity(0.32),
                  strokeWidth: 3,
                ),
                ChartInput(
                  strokeWidth: 3,
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
      AnimatedOpacity(
        opacity: _hasError ? 1 : 0,
        duration: Duration(milliseconds: 200),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).errorColor,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          padding: EdgeInsets.all(8),
          child: Text(
            kSomePointIsInvalid[_language],
            style: Theme.of(context).textTheme.headline6.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
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
    try {
      final plotData = _piecewiseFunction.callFromLinearSpace(
        LinearSpace(
          start: minChart,
          end: maxChart,
          length: numberOfPoints,
        ),
      );

      final _higherValue = plotData.fold(
          0,
          (previousValue, element) => previousValue.abs() > element.y.abs()
              ? previousValue.abs()
              : element.y.abs());

      _maxY = 1.25 * (_higherValue < 1 ? 1 : _higherValue);
      _chartData = plotData;
      _hasError = false;
    } catch (e) {
      _chartData = [];
      _hasError = true;
    }
  }

  void nextPage() {
    Navigator.of(context).pushNamed('/func-output', arguments: [
      [minFunctionWindow, maxFunctionWindow],
      _piecewiseFunction,
    ]);
  }
}
