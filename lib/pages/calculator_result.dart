import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tex/flutter_tex.dart';
import '../strings/generators.dart';
import '../strings/constants.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import '../math/fourier_series.dart';
import '../math/piecewuise_function.dart';
import '../widgets/text_loading_widget.dart';

enum SpectrumMode { Trigonometric, Polar }
enum SpectrumView { First, Second, Both }

class CalculatorResultPage extends StatefulWidget {
  @override
  _CalculatorResultPageState createState() => _CalculatorResultPageState();
}

class _CalculatorResultPageState extends State<CalculatorResultPage> {
  String _language;
  TrigonometricFourierSeries _trigonometricFourierSeries;
  SpectrumMode _spectrumMode = SpectrumMode.Trigonometric;
  SpectrumView _spectrumView = SpectrumView.Both;
  PiecewiseFunction _piecewiseFunction;
  double _maxY, _chartStart, _dt, _start, _end;
  int _numberOfPoints = 1024;
  bool _init = true, _showF = true, _showT = true;
  RangeValues _harmonicFilter;
  List<FlSpot> _functionData,
      _seriesData,
      _filteredSeriesData,
      _aData,
      _bData,
      _cData,
      _omegaData;

  @override
  Future<void> didChangeDependencies() async {
    if (_init) {
      _language = getLocationCode(context);
      final data = ModalRoute.of(context).settings.arguments as List;
      final _domainRepresentation = data[0] as RangeValues;
      _start = _domainRepresentation.start;
      _end = _domainRepresentation.end;
      _piecewiseFunction = data[1];
      _trigonometricFourierSeries =
          await compute<List, TrigonometricFourierSeries>(
              TrigonometricFourierSeries.make,
              [_piecewiseFunction, _start, _end]);
      _harmonicFilter = RangeValues(
          0, (_trigonometricFourierSeries.a.length - 1).floorToDouble());
      _functionData = List<FlSpot>(_numberOfPoints);
      double meanPoint = (_start + _end) / 2, period = -_start + _end;
      _chartStart = meanPoint - period * 1.5;
      _dt = (3 * period) / (_numberOfPoints - 1);
      for (int i = 0; i < _numberOfPoints; i++) {
        double t = _chartStart + _dt * i, y = _piecewiseFunction.at(t);
        _functionData[i] = FlSpot(t, y);
      }
      _seriesData = List<FlSpot>(_numberOfPoints);
      _aData = List<FlSpot>();
      _bData = List<FlSpot>();
      _cData = List<FlSpot>();
      _omegaData = List<FlSpot>();
      _filteredSeriesData = List<FlSpot>(_numberOfPoints);
      for (int i = 0; i < _numberOfPoints; i++) {
        _seriesData[i] = FlSpot(_functionData[i].x,
            _trigonometricFourierSeries.at(_functionData[i].x));
        _filteredSeriesData[i] = FlSpot(
            _functionData[i].x,
            _trigonometricFourierSeries.at(_functionData[i].x,
                _harmonicFilter.end.round(), _harmonicFilter.start.round()));
      }
      //find max |Y|
      _maxY = 0;
      for (FlSpot yValue in _seriesData) {
        double absY = yValue.y.abs();
        if (absY > _maxY) _maxY = absY;
      }
      _maxY = 1.25 * _maxY;
      double termLength = 0.5, termOffset = 1, count = 0;
      for (int n = 0; n < _trigonometricFourierSeries.a.length; n++) {
        _aData.add(FlSpot(count, 0.0));
        _bData.add(FlSpot(count, 0.0));
        _cData.add(FlSpot(count, 0.0));
        _omegaData.add(FlSpot(count, 0.0));
        _aData.add(FlSpot(count, _trigonometricFourierSeries.a[n]));
        _bData.add(FlSpot(count, _trigonometricFourierSeries.b[n]));
        _cData.add(FlSpot(count, _trigonometricFourierSeries.c[n]));
        _omegaData.add(FlSpot(
            count,
            _trigonometricFourierSeries.omega[n] *
                _trigonometricFourierSeries.maxTerm /
                pi));
        count += termLength;
        _aData.add(FlSpot(count, _trigonometricFourierSeries.a[n]));
        _bData.add(FlSpot(count, _trigonometricFourierSeries.b[n]));
        _cData.add(FlSpot(count, _trigonometricFourierSeries.c[n]));
        _omegaData.add(FlSpot(
            count,
            _trigonometricFourierSeries.omega[n] *
                _trigonometricFourierSeries.maxTerm /
                pi));
        _aData.add(FlSpot(count, 0.0));
        _bData.add(FlSpot(count, 0.0));
        _cData.add(FlSpot(count, 0.0));
        _omegaData.add(FlSpot(count, 0.0));
        count += termOffset;
        _aData.add(FlSpot(count, 0.0));
        _bData.add(FlSpot(count, 0.0));
        _cData.add(FlSpot(count, 0.0));
        _omegaData.add(FlSpot(count, 0.0));
      }
      _aData.removeLast();
      _bData.removeLast();
      _cData.removeLast();
      _omegaData.removeLast();
      setState(() {
        _init = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              children: <Widget>[
                Card(
                  child: Column(
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
                        child: TeXView(
                          child: TeXViewDocument(
                            fourierSeriesResultText(
                                discontinuities: _piecewiseFunction.domainValues
                                    .map((v) => v.toStringAsFixed(2))
                                    .toList(),
                                expressions: _piecewiseFunction.pieces
                                    .map((f) => f.tex)
                                    .toList(),
                                start: _start,
                                end: _end,
                                rmsValue: _trigonometricFourierSeries.rms,
                                language: _language),
                          ),
                          renderingEngine: TeXViewRenderingEngine.mathjax(),
                          loadingWidgetBuilder: (context) => TexLoadingWidget(
                            height: (200 +
                                    _piecewiseFunction.domainValues.length * 10)
                                .toDouble(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
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
                        child: LineChart(LineChartData(
                          titlesData: FlTitlesData(
                            show: false,
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          extraLinesData: ExtraLinesData(horizontalLines: [
                            HorizontalLine(
                                y: 0, strokeWidth: 0.5, color: Colors.black54)
                          ]),
                          lineTouchData: LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                                spots: _seriesData,
                                //     isCurved: true,
                                //    curveSmoothness: 0,
                                //    preventCurveOverShooting: true,
                                barWidth: 1,
                                show: _showT,
                                dotData: FlDotData(show: false),
                                colors: [Colors.black]),
                            LineChartBarData(
                                //   isStrokeCapRound: true,
                                spots: _functionData,
                                show: _showF,
                                //   isCurved: true,
                                barWidth: 1,
                                dotData: FlDotData(show: false),
                                colors: [Colors.blueGrey.withOpacity(0.75)]),
                          ],
                          minY: -_maxY,
                          maxY: _maxY,
                        )),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Switch(
                                value: _showF,
                                activeColor: Colors.blueGrey,
                                onChanged: (value) {
                                  setState(() {
                                    _showF = value;
                                  });
                                },
                              ),
                              Text('x(t)'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Switch(
                                value: _showT,
                                activeColor: Colors.black,
                                onChanged: (value) {
                                  setState(() {
                                    _showT = value;
                                  });
                                },
                              ),
                              Text('s(t)'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Card(
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
                          LineChartData(
                            titlesData: FlTitlesData(
                              show: false,
                            ),
                            extraLinesData: ExtraLinesData(horizontalLines: [
                              HorizontalLine(
                                  y: 0, strokeWidth: 0.5, color: Colors.black54)
                            ]),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            lineTouchData: LineTouchData(enabled: false),
                            lineBarsData: [
                              LineChartBarData(
                                  spots: _filteredSeriesData,
                                  //     isCurved: true,
                                  //    curveSmoothness: 0,
                                  //    preventCurveOverShooting: true,
                                  barWidth: 1,
                                  dotData: FlDotData(show: false),
                                  colors: [Colors.black]),
                            ],
                            minY: -_maxY,
                            maxY: _maxY,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: RangeSlider(
                          activeColor: Colors.black,
                          inactiveColor: Colors.blueGrey,
                          min: 0,
                          max: (_trigonometricFourierSeries.a.length - 1)
                              .toDouble(),
                          values: _harmonicFilter,
                          labels: _labelGenerator(_harmonicFilter),
                          divisions: (_trigonometricFourierSeries.a.length - 1),
                          onChanged: (value) => setState(() {
                            _harmonicFilter = value;
                          }),
                          onChangeEnd: _updateFilteredChart,
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
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
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: Text(kFrequencyChartTitleText[
                                              _language]),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: <Widget>[
                                                for (int i = 0;
                                                    i <
                                                        _trigonometricFourierSeries
                                                            .a.length;
                                                    i++)
                                                  Text(
                                                      'A$i = ${_trigonometricFourierSeries.a[i].toStringAsFixed(3)}'
                                                      '\nB$i = ${_trigonometricFourierSeries.b[i].toStringAsFixed(3)}'
                                                      '\n|C|$i = ${_trigonometricFourierSeries.c[i].toStringAsFixed(3)}'
                                                      '\n∠C$i = ${_trigonometricFourierSeries.omega[i].toStringAsFixed(3)} rad '
                                                      '(${(_trigonometricFourierSeries.omega[i] * 180 / pi).toStringAsFixed(3)}°)\n')
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
                                        ));
                              },
                            )
                          ],
                        ),
                      ),
                      Card(
                        elevation: 2,
                        clipBehavior: Clip.hardEdge,
                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(
                              show: false,
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            extraLinesData: ExtraLinesData(horizontalLines: [
                              HorizontalLine(
                                  y: 0, strokeWidth: 0.5, color: Colors.black54)
                            ]),
                            lineTouchData: LineTouchData(enabled: false),
                            lineBarsData: [
                              LineChartBarData(
                                  spots: _spectrumMode ==
                                          SpectrumMode.Trigonometric
                                      ? _aData
                                      : _cData,
                                  //     isCurved: true,
                                  //    curveSmoothness: 0,
                                  //    preventCurveOverShooting: true,
                                  barWidth: 1,
                                  show: _spectrumView != SpectrumView.Second,
                                  dotData: FlDotData(show: false),
                                  colors: [Colors.blueGrey.withOpacity(0.75)]),
                              LineChartBarData(
                                  spots: _spectrumMode ==
                                          SpectrumMode.Trigonometric
                                      ? _bData
                                      : _omegaData,
                                  show: _spectrumView != SpectrumView.First,
                                  //     isCurved: true,
                                  //    curveSmoothness: 0,
                                  //    preventCurveOverShooting: true,
                                  barWidth: 1,
                                  dotData: FlDotData(show: false),
                                  colors: [Colors.black.withOpacity(0.75)]),
                            ],
                            minY: -_trigonometricFourierSeries.maxTerm,
                            maxY: _trigonometricFourierSeries.maxTerm,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoSlidingSegmentedControl<SpectrumMode>(
                          children: {
                            SpectrumMode.Trigonometric: Text('An Bn'),
                            SpectrumMode.Polar: Text('|Cn| ∠Cn ')
                          },
                          groupValue: _spectrumMode,
                          onValueChanged: (value) {
                            setState(() {
                              _spectrumMode = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoSlidingSegmentedControl<SpectrumView>(
                          children: {
                            SpectrumView.First: Text(
                                _spectrumMode == SpectrumMode.Trigonometric
                                    ? 'An'
                                    : '|Cn|'),
                            SpectrumView.Both: Text(kBothText[_language]),
                            SpectrumView.Second: Text(
                                _spectrumMode == SpectrumMode.Trigonometric
                                    ? 'Bn'
                                    : '∠Cn'),
                          },
                          groupValue: _spectrumView,
                          onValueChanged: (value) {
                            setState(() {
                              _spectrumView = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _updateFilteredChart(RangeValues values) {
    final newFilteredDataSeries = List<FlSpot>();
    int start = _harmonicFilter.start.toInt(),
        end = _harmonicFilter.end.toInt();

    for (int i = 0; i < _numberOfPoints; i++) {
      newFilteredDataSeries.add(FlSpot(_functionData[i].x,
          _trigonometricFourierSeries.at(_functionData[i].x, end, start)));
    }

    setState(() {
      _filteredSeriesData = newFilteredDataSeries;
      _harmonicFilter = values;
    });
  }

  String _subLabelGenerator(double value) =>
      value == 0 ? 'DC' : value == 1 ? 'F' : value.toStringAsFixed(0) + 'H';

  RangeLabels _labelGenerator(RangeValues value) {
    return RangeLabels(
        _subLabelGenerator(value.start), _subLabelGenerator(value.end));
  }
}
