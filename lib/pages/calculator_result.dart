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
import '../math/piecewise_function.dart';
import '../widgets/text_loading_widget.dart';

extension psdfsdf on Point {
  FlSpot get toSpot => FlSpot(this.x, this.y);
}

enum SpectrumMode { Trigonometric, Polar }
enum SpectrumView { First, Second, Both }

class CalculatorResultPage extends StatefulWidget {
  @override
  _CalculatorResultPageState createState() => _CalculatorResultPageState();
}

class _CalculatorResultPageState extends State<CalculatorResultPage> {
  String _language;
  FourierSeries _trigonometricFourierSeries;
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

  static FourierSeries _compute(List args) {
    return FourierSeries.evaluate(args[0],
        start: args[1], end: args[2], numberOfTerms: 200);
  }

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
          await compute(_compute, [_piecewiseFunction, _start, _end]);
      _harmonicFilter = RangeValues(
          0,
          (_trigonometricFourierSeries.cosineCoefficients.length - 1)
              .floorToDouble());
      double meanPoint = (_start + _end) / 2, period = -_start + _end;
      _chartStart = meanPoint - period * 1.5;
      _dt = (3 * period) / (_numberOfPoints - 1);
      final evalFunctData =
          _piecewiseFunction.discretize(start: _start, end: _end, length: 1024);
      _functionData = evalFunctData.map((e) => FlSpot(e.x, e.y)).toList();
      _seriesData = List<FlSpot>(_numberOfPoints);
      _aData = List<FlSpot>();
      _bData = List<FlSpot>();
      _cData = List<FlSpot>();
      _omegaData = List<FlSpot>();
      _filteredSeriesData = List<FlSpot>(_numberOfPoints);
      for (int i = 0; i < _numberOfPoints; i++) {
        _seriesData[i] =
            _trigonometricFourierSeries.call(_functionData[i].x).toSpot;
        _filteredSeriesData[i] = _trigonometricFourierSeries
            .call(
              _functionData[i].x,
              higherCutoffIndex: _harmonicFilter.end.round(),
              lowerCutoffIndex: _harmonicFilter.start.round(),
            )
            .toSpot;
      }
      //find max |Y|
      _maxY = 0;
      for (FlSpot yValue in _seriesData) {
        double absY = yValue.y.abs();
        if (absY > _maxY) _maxY = absY;
      }
      _maxY = 1.25 * _maxY;
      double termLength = 0.5, termOffset = 1, count = 0;
      for (int n = 0;
          n < _trigonometricFourierSeries.cosineCoefficients.length;
          n++) {
        _aData.add(FlSpot(count, 0.0));
        _bData.add(FlSpot(count, 0.0));
        _cData.add(FlSpot(count, 0.0));
        _omegaData.add(FlSpot(count, 0.0));
        _aData.add(
            FlSpot(count, _trigonometricFourierSeries.cosineCoefficients[n]));
        _bData.add(
            FlSpot(count, _trigonometricFourierSeries.sineCoefficients[n]));
        _cData.add(FlSpot(
            count, _trigonometricFourierSeries.amplitudeCoefficients[n]));
        _omegaData.add(FlSpot(
            count,
            _trigonometricFourierSeries.phaseCoefficients[n] *
                _trigonometricFourierSeries.higherAmplitude /
                pi));
        count += termLength;
        _aData.add(
            FlSpot(count, _trigonometricFourierSeries.cosineCoefficients[n]));
        _bData.add(
            FlSpot(count, _trigonometricFourierSeries.sineCoefficients[n]));
        _cData.add(FlSpot(
            count, _trigonometricFourierSeries.amplitudeCoefficients[n]));
        _omegaData.add(FlSpot(
            count,
            _trigonometricFourierSeries.phaseCoefficients[n] *
                _trigonometricFourierSeries.higherAmplitude /
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
                                discontinuities: _piecewiseFunction
                                    .discontinuities
                                    .map((v) => v.toStringAsFixed(2))
                                    .toList(),
                                expressions: _piecewiseFunction.expressions
                                    .map((f) => f.tex)
                                    .toList(),
                                start: _start,
                                end: _end,
                                rmsValue:
                                    _trigonometricFourierSeries.rootMeanSquare,
                                language: _language),
                          ),
                          renderingEngine: TeXViewRenderingEngine.mathjax(),
                          loadingWidgetBuilder: (context) => TexLoadingWidget(
                            height: (200 +
                                    _piecewiseFunction.discontinuities.length *
                                        10)
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
                          max: (_trigonometricFourierSeries
                                      .cosineCoefficients.length -
                                  1)
                              .toDouble(),
                          values: _harmonicFilter,
                          labels: _labelGenerator(_harmonicFilter),
                          divisions: (_trigonometricFourierSeries
                                  .cosineCoefficients.length -
                              1),
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
                                                            .cosineCoefficients
                                                            .length;
                                                    i++)
                                                  Text(
                                                      'A$i = ${_trigonometricFourierSeries.cosineCoefficients[i].toStringAsFixed(3)}'
                                                      '\nB$i = ${_trigonometricFourierSeries.sineCoefficients[i].toStringAsFixed(3)}'
                                                      '\n|C|$i = ${_trigonometricFourierSeries.amplitudeCoefficients[i].toStringAsFixed(3)}'
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
                            minY: -_trigonometricFourierSeries.higherAmplitude,
                            maxY: _trigonometricFourierSeries.higherAmplitude,
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
    int start = _harmonicFilter.start.toInt(),
        end = _harmonicFilter.end.toInt();

    final newFilteredDataSeries = _trigonometricFourierSeries.discretize(
        start: _start,
        end: _end,
        length: 1024,
        lowerCutoffIndex: start,
        higherCutoffIndex: end);

    setState(() {
      _filteredSeriesData =
          newFilteredDataSeries.map((e) => FlSpot(e.x, e.y)).toList();
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
