import 'dart:math';

import 'package:catex/catex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ifs/math/linear_space.dart';
import 'package:ifs/widgets/line_chart.dart';
import 'package:ifs/widgets/piecewise_function_display.dart';

import '../math/fourier_series.dart';
import '../math/piecewise_function.dart';
import '../strings/constants.dart';
import '../widgets/custom_scaffold.dart';

enum SpectrumView { An, Bn, Amplitude }

class FunctionOutputPage extends StatefulWidget {
  @override
  _FunctionOutputPageState createState() => _FunctionOutputPageState();
}

class _FunctionOutputPageState extends State<FunctionOutputPage> {
  LinearSpace functionsSpace;
  String _language;
  FourierSeries _trigonometricFourierSeries;
  SpectrumView _spectrumView = SpectrumView.An;
  PiecewiseFunction _piecewiseFunction;
  double _maxY, _chartStart, _dt, _start, _end;
  int _numberOfPoints = 1024;
  bool _init = true, _showF = true, _showT = true;
  RangeValues _harmonicFilter;
  List<Point> _functionData,
      _seriesData,
      _filteredSeriesData,
      _aData,
      _bData,
      _cData,
      _omegaData;

  int _page = 1;

  static FourierSeries _compute(List args) {
    return FourierSeries.evaluate(
      args[0],
      representationSpace: args[1],
      numberOfTerms: 50,
    );
  }

  @override
  Future<void> didChangeDependencies() async {
    if (_init) {
      try {
        _language = getLocationCode(context);
        final data = ModalRoute.of(context).settings.arguments as List;
        _start = data[0][0];
        _end = data[0][1];
        _piecewiseFunction = data[1];

        compute(_compute, [
          _piecewiseFunction,
          LinearSpace(start: _start, end: _end, length: 100000)
        ]).then((value) {
          _trigonometricFourierSeries = value;
          _harmonicFilter = RangeValues(
              0,
              (_trigonometricFourierSeries.aCoefficients.length - 1)
                  .floorToDouble());
          double meanPoint = (_start + _end) / 2, period = -_start + _end;
          _chartStart = meanPoint - period * 1.5;
          _dt = (3 * period) / (_numberOfPoints - 1);
          functionsSpace = LinearSpace(
              start: meanPoint - _trigonometricFourierSeries.period,
              end: meanPoint + _trigonometricFourierSeries.period,
              length: 1024);

          _functionData =
              _piecewiseFunction.callFromLinearSpace(functionsSpace);
          _seriesData = List<Point>(_numberOfPoints);
          _filteredSeriesData = List<Point>(_numberOfPoints);
          for (int i = 0; i < _numberOfPoints; i++) {
            _seriesData[i] =
                _trigonometricFourierSeries.call(_functionData[i].x);
            _filteredSeriesData[i] = _trigonometricFourierSeries.call(
              _functionData[i].x,
              higherCutoffIndex: _harmonicFilter.end.round(),
              lowerCutoffIndex: _harmonicFilter.start.round(),
            );
          }
          //find max |Y|
          _maxY = 0;
          for (Point yValue in _seriesData) {
            double absY = yValue.y.abs();
            if (absY > _maxY) _maxY = absY;
          }
          _maxY = 1.25 * _maxY;

          _aData =
              List<Point>(_trigonometricFourierSeries.aCoefficients.length);
          _bData =
              List<Point>(_trigonometricFourierSeries.aCoefficients.length);
          _cData =
              List<Point>(_trigonometricFourierSeries.aCoefficients.length);
          _omegaData =
              List<Point>(_trigonometricFourierSeries.aCoefficients.length);

          for (int i = 0;
              i < _trigonometricFourierSeries.aCoefficients.length;
              i++) {
            _aData[i] =
                Point(i * 1.0, _trigonometricFourierSeries.aCoefficients[i]);
            _bData[i] =
                Point(i * 1.0, _trigonometricFourierSeries.bCoefficients[i]);
            _cData[i] = Point(
                i * 1.0, _trigonometricFourierSeries.magnitudeCoefficients[i]);
            _omegaData[i] = Point(
                i * 1.0,
                _trigonometricFourierSeries.phaseCoefficients[i] %
                    (2 * pi) /
                    (2 * _maxY));
          }

          setState(() {
            _init = false;
          });
        });
      } catch (e) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      }
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(kCalculatorResultName[_language]),
      ),
      body: _init
          ? Center(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoActivityIndicator(),
                Text(kWaitingForCalculationText[_language])
              ],
            ))
          : ListView(
              padding: EdgeInsets.all(20),
              children: _page == 0
                  ? [
                      _buildFirstPage(),
                      _buildSecondPage(),
                    ]
                  : [
                      _buildThirdPage(),
                      _buildForthPage(),
                    ],
            ),
      bottomNavigationBar: !_init
          ? BottomNavigationBar(
              currentIndex: _page,
              onTap: (int index) {
                if (_page == index) return;
                setState(() => _page = index);
              },
              items: [
                BottomNavigationBarItem(
                  label: '1',
                  icon: Text(
                    'x(t)',
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.pink),
                  ),
                ),
                BottomNavigationBarItem(
                  label: '2',
                  icon: Icon(
                    Icons.show_chart,
                    color: Colors.pink,
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildFirstPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            kInputDataText[_language],
            style: Theme.of(context).textTheme.title,
          ),
        ),
        Card(
          elevation: 2,
          clipBehavior: Clip.hardEdge,
          child: PiecewiseFunctionDisplay(_piecewiseFunction),
        ),
      ],
    );
  }

  Widget _buildSecondPage() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              kTFGraphsText[_language],
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Card(
            elevation: 2,
            clipBehavior: Clip.hardEdge,
            child: LineChart(
              boundaries: ChartBoundaries(
                maxY: _maxY,
                minY: -_maxY,
              ),
              input: [
                ChartInput(
                  samples: _seriesData,
                  strokeColor: Colors.black54,
                ),
                ChartInput(
                  strokeColor: Colors.blueGrey.withOpacity(0.50),
                  samples: _functionData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPage() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              kTFilteredText[_language],
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Card(
            elevation: 2,
            clipBehavior: Clip.hardEdge,
            child: LineChart(
              boundaries: ChartBoundaries(
                maxY: _maxY,
                minY: -_maxY,
              ),
              input: [
                ChartInput(
                  samples: _seriesData,
                  strokeColor: Colors.black54,
                ),
                ChartInput(
                    strokeColor: Colors.black, samples: _filteredSeriesData),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: RangeSlider(
              activeColor: Colors.black,
              inactiveColor: Colors.blueGrey,
              min: 0,
              max: (_trigonometricFourierSeries.aCoefficients.length - 1)
                  .toDouble(),
              values: _harmonicFilter,
              labels: _labelGenerator(_harmonicFilter),
              divisions: (_trigonometricFourierSeries.aCoefficients.length - 1),
              onChanged: (value) => setState(() {
                _harmonicFilter = value;
              }),
              onChangeEnd: _updateFilteredChart,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForthPage() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  kFrequencySpectrumText[_language],
                  style: Theme.of(context).textTheme.title,
                ),
                FlatButton(
                  child: Text(kViewChartText[_language]),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(kFrequencyChartTitleText[_language]),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              for (int i = 0;
                                  i <
                                      _trigonometricFourierSeries
                                          .aCoefficients.length;
                                  i++)
                                Text(
                                    'A$i = ${_trigonometricFourierSeries.aCoefficients[i].toStringAsFixed(3)}'
                                    '\nB$i = ${_trigonometricFourierSeries.bCoefficients[i].toStringAsFixed(3)}'
                                    '\n|C|$i = ${_trigonometricFourierSeries.magnitudeCoefficients[i].toStringAsFixed(3)}'
                                    '\n∠C$i = ${_trigonometricFourierSeries.phaseCoefficients[i].toStringAsFixed(3)} rad '
                                    '(${(_trigonometricFourierSeries.phaseCoefficients[i] * 180 / pi).toStringAsFixed(3)}°)\n')
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Ok'),
                            textColor: Colors.black,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          Card(
            elevation: 2,
            //     clipBehavior: Clip.hardEdge,
            child: LineChart(
              boundaries: ChartBoundaries(
                maxY: _trigonometricFourierSeries.higherAmplitude * 1.1,
                minY: -_trigonometricFourierSeries.higherAmplitude * 1.1,
                minX: -1.0,
                maxX: _trigonometricFourierSeries.aCoefficients.length + 0.0,
              ),
              input: [
                ChartInput(
                  samples: _spectrumView == SpectrumView.An
                      ? _aData
                      : _spectrumView == SpectrumView.Bn
                          ? _bData
                          : _cData,
                  strokeColor: Colors.black,
                  isDiscrete: true,
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSlidingSegmentedControl<SpectrumView>(
              children: {
                SpectrumView.An: buildCaTeX(
                  r'A_n',
                  context,
                ),
                SpectrumView.Bn: buildCaTeX(
                  r'B_n',
                  context,
                ),
                SpectrumView.Amplitude: buildCaTeX(
                  r'\sqrt{A_n^2+B_n^2}',
                  context,
                ),
              },
              groupValue: _spectrumView,
              onValueChanged: (value) => setState(
                () => _spectrumView = value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateFilteredChart(RangeValues values) {
    int start = _harmonicFilter.start.toInt(),
        end = _harmonicFilter.end.toInt();

    final newFilteredDataSeries =
        _trigonometricFourierSeries.callFromLinearSpace(
      space: functionsSpace,
      lowerCutoffIndex: start,
      higherCutoffIndex: end,
    );

    setState(() {
      _filteredSeriesData =
          newFilteredDataSeries.map((e) => Point(e.x, e.y)).toList();
      _harmonicFilter = values;
    });
  }

  String _subLabelGenerator(double value) => value == 0
      ? 'DC'
      : value == 1
          ? 'F'
          : value.toStringAsFixed(0) + 'H';

  RangeLabels _labelGenerator(RangeValues value) {
    return RangeLabels(
        _subLabelGenerator(value.start), _subLabelGenerator(value.end));
  }

  Widget buildCaTeX(String expression, BuildContext context) {
    return DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.headline6,
      child: CaTeX(expression),
    );
  }
}
