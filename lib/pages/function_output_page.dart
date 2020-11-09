import 'dart:math';

import 'package:catex/catex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ifs/math/linear_space.dart';
import 'package:ifs/widgets/coefficients_list_view.dart';
import 'package:ifs/widgets/content_page.dart';
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

class _FunctionOutputPageState extends State<FunctionOutputPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
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

  static FourierSeries _compute(List args) {
    return FourierSeries.evaluate(
      args[0],
      representationSpace: args[1],
      numberOfTerms: 50,
    );
  }

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 5, vsync: this);
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    if (_init) {
      try {
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
        print(e);
      }
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _language = getLocationCode(context);

    return CustomScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(kCalculatorResultName[_language]),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelPadding: EdgeInsets.symmetric(horizontal: 32),
          tabs: [
            Tab(
              text: 's(t) Info',
              icon: Container(),
            ),
            Tab(
              text: 'x(t) s(t) Charts',
              icon: Container(),
            ),
            Tab(
              text: kFilterText[_language],
              icon: Container(),
            ),
            Tab(
              text: 'A[n] B[n] Charts',
              icon: Container(),
            ),
            Tab(
              text: 'A[n] B[n] List',
              icon: Container(),
            ),
          ],
        ),
      ),
      body: _init
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CupertinoActivityIndicator(),
                  Text(kWaitingForCalculationText[_language])
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFirstPage(),
                _buildSecondPage(),
                _buildThirdPage(),
                _buildForthPage(),
                _buildFifthPage(),
              ],
            ),
    );
  }

  Widget _buildFirstPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ContentPage(
        title: kInputDataText[_language],
        content: PiecewiseFunctionDisplay(_piecewiseFunction),
      ),
    );
  }

  Widget _buildSecondPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ContentPage(
        title: kTFGraphsText[_language],
        content: Card(
          child: LayoutBuilder(
            builder: (context, constraints) => LineChart(
              size: Size(constraints.maxWidth, constraints.maxWidth) * 0.9,
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
        ),
      ),
    );
  }

  Widget _buildThirdPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ContentPage(
        title: kTFilteredText[_language],
        content: Card(
          clipBehavior: Clip.hardEdge,
          child: LayoutBuilder(
            builder: (context, constraints) => LineChart(
              size: Size(constraints.maxWidth, constraints.maxWidth) * 0.9,
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
        ),
        subContent: RangeSlider(
          activeColor: Colors.black,
          inactiveColor: Colors.blueGrey,
          min: 0,
          max:
              (_trigonometricFourierSeries.aCoefficients.length - 1).toDouble(),
          values: _harmonicFilter,
          labels: _labelGenerator(_harmonicFilter),
          divisions: (_trigonometricFourierSeries.aCoefficients.length - 1),
          onChanged: (value) => setState(() {
            _harmonicFilter = value;
          }),
          onChangeEnd: _updateFilteredChart,
        ),
      ),
    );
  }

  Widget _buildForthPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ContentPage(
        title: kFrequencySpectrumText[_language],
        content: Card(
          child: LayoutBuilder(
            builder: (context, constraints) => LineChart(
              size: Size(constraints.maxWidth, constraints.maxWidth) * 0.9,
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
        ),
        subContent: CupertinoSlidingSegmentedControl<SpectrumView>(
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
    );
  }

  Widget _buildFifthPage() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: ContentPage(
        withPadding: false,
        title: kFrequencySpectrumText[_language],
        content: Flexible(
          child: CoefficientsListView(_trigonometricFourierSeries),
        ),
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
