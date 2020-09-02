import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ifs/math/linear_space.dart';
import 'dart:math';
import 'package:function_tree/function_tree.dart' as tree;
import 'package:fl_chart/fl_chart.dart';
import 'package:ifs/widgets/multi_slider.dart';
import '../math/piecewise_function.dart';

class CalculatorInputPage extends StatefulWidget {
  @override
  _CalculatorInputPageState createState() => _CalculatorInputPageState();
}

class _CalculatorInputPageState extends State<CalculatorInputPage> {
  static const maxPieces = 5;
  static const minPieces = 1;

  ///general
  int _tabIndex = 0;

  ///step zero
  final List<TextEditingController> _piecesControllers = [
    TextEditingController(text: '-sin(t)'),
    TextEditingController(text: 'sin(t)'),
  ];
  final _formKey = GlobalKey<FormState>();
  PiecewiseFunction _piecewiseFunction;

  ///step one
  List<double> values;
  List<tree.SingleVariableFunction> _functions;
  double maxChart = pi;
  double minChart = -pi;

  List<FlSpot> _chartData;
  double _maxY;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (int index) {
          if (_tabIndex == index) return;

          if (index == 0) {
            setState(() {
              _tabIndex = index;
            });
          } else {
            if (!_formKey.currentState.validate()) return;

            _tabIndex = index;

            generateUserInput();
            updateUserInput();
            _updateChartData();

            setState(() {});
          }
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
          child: Column(
            children: _tabIndex == 0 ? buildFirstPage() : buildSecondPage(),
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
              onPressed: _piecesControllers.length < maxPieces
                  ? () {
                      setState(() {
                        _piecesControllers.add(
                          TextEditingController(),
                        );
                      });
                    }
                  : null,
            ),
          ),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.remove),
              onPressed: _piecesControllers.length > minPieces
                  ? () {
                      setState(() {
                        _piecesControllers.removeLast();
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
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                extraLinesData: ExtraLinesData(horizontalLines: [
                  HorizontalLine(y: 0, strokeWidth: 0.5, color: Colors.black54)
                ]),
                maxY: _maxY,
                minY: -_maxY,
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(show: false
                    //bottomTitles:
                    //   SideTitles(showTitles: true, getTitles: _xGenerator),
                    ),
                lineTouchData: LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                      spots: _chartData,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      colors: [Colors.blueGrey]),
                  LineChartBarData(
                      spots: _chartData
                          .where((element) =>
                              element.x > values.first &&
                              element.x < values.last)
                          .toList(),
                      barWidth: 5,
                      dotData: FlDotData(show: false),
                      colors: [Colors.black]),
                ],
              ),
            ),
          ),
          MultiSlider(
            values: values,
            onChanged: (newValues) => setState(() {
              values = newValues;
              updateUserInput();
              _updateChartData();
            }),
            max: maxChart,
            min: minChart,
          ),
        ],
      ),
      FlatButton(
        child: Text('Plotar Serie'),
        onPressed: nextPage,
      )
    ];
  }

  List<tree.SingleVariableFunction> _parseFunctions() {
    return _piecesControllers
        .map<String>((controller) => controller.text)
        .map<tree.SingleVariableFunction>(
          (text) => text.toSingleVariableFunction('t'),
        )
        .toList();
  }

  List<double> generateValues() {
    int numberOfValues = _functions.length + 1;
    double range = maxChart - minChart;
    return List<double>.generate(numberOfValues,
        (index) => range * index / (numberOfValues - 1) + minChart);
  }

  void generateUserInput() {
    _functions = _parseFunctions();
    values = generateValues();
  }

  void updateUserInput() {
    _piecewiseFunction = PiecewiseFunction(
        expressions: _functions,
        discontinuities: values.getRange(1, values.length - 1).toList());
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
    _chartData = plotData.map((e) => FlSpot(e.x, e.y)).toList();
  }

  void nextPage() {
    Navigator.of(context).pushNamed('/calc-result', arguments: [
      [values.first, values.last],
      _piecewiseFunction,
    ]);
  }
}
