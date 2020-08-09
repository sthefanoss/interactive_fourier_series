import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:ifs/math/piecewuise_function.dart';
import 'package:ifs/strings/constants.dart';
import '../strings/regular_expressions.dart';
import './../widgets/radio_text.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/text_loading_widget.dart';
import '../strings/generators.dart';

typedef FormFieldValidatorWithIndex<VALUE, INDEX> = String Function(
    VALUE value, INDEX index);

class StepZero extends StatelessWidget {
  const StepZero({this.expressionsCount, this.onChanged});
  final Function onChanged;
  final int expressionsCount;
  @override
  Widget build(BuildContext context) {
    final _language = getLocationCode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          elevation: 2,
          clipBehavior: Clip.hardEdge,
          child: TeXView(
            child: TeXViewDocument(
              kDiscontinuitiesHintText[_language],
            ),
            renderingEngine: TeXViewRenderingEngine.mathjax(),
            loadingWidgetBuilder: (context) => TexLoadingWidget(
              height: 250,
            ),
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
                  kPiecesNumberText[_language],
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int i = 1; i <= 5; i++)
                      RadioText<int>(
                          value: i,
                          text: '$i',
                          groupValue: expressionsCount,
                          onChanged: onChanged),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StepOne extends StatelessWidget {
  const StepOne(
      {this.formOneKey,
      this.expressionsCount,
      this.formOneTextControllers,
      this.validator});
  final GlobalKey<FormState> formOneKey;
  final List<TextEditingController> formOneTextControllers;
  final int expressionsCount;
  final FormFieldValidatorWithIndex<String, int> validator;
  @override
  Widget build(BuildContext context) {
    final _language = getLocationCode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: TeXView(
            child: TeXViewDocument(
              discontinuitiesHintText(expressionsCount, _language),
            ),
            renderingEngine: TeXViewRenderingEngine.mathjax(),
            loadingWidgetBuilder: (context) => TexLoadingWidget(
              height: 250,
            ),
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
                  kDiscontinuitiesText[_language],
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              Form(
                key: formOneKey,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    for (int i = 0; i < formOneTextControllers.length; i++)
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: TextFormField(
                          controller: formOneTextControllers[i],
                          validator: (value) => validator(value, i),
                          decoration: InputDecoration(
                              labelText: 't${i + 1}',
                              border: OutlineInputBorder()),
                        ),
                        width: 150,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StepTwo extends StatelessWidget {
  const StepTwo(
      {this.validator,
      this.formTwoKey,
      this.formTwoTextControllers,
      this.domainValues});
  final GlobalKey<FormState> formTwoKey;
  final List<TextEditingController> formTwoTextControllers;
  final List<double> domainValues;
  final FormFieldValidatorWithIndex<String, int> validator;
  @override
  Widget build(BuildContext context) {
    final _language = getLocationCode(context);
    return Form(
      key: formTwoKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            elevation: 2,
            clipBehavior: Clip.hardEdge,
            child: TeXView(
              child: TeXViewDocument(
                piecesHintText(
                    domainValues
                        .map((discontinuities) =>
                            discontinuities.toStringAsFixed(2))
                        .toList(),
                    _language),
              ),
              renderingEngine: TeXViewRenderingEngine.mathjax(),
              loadingWidgetBuilder: (context) => TexLoadingWidget(
                height: 250,
              ),
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
                    kPiecesOfFtText[_language],
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                for (int i = 0; i < formTwoTextControllers.length; i++)
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      controller: formTwoTextControllers[i],
                      validator: (value) => validator(value, i),
                      decoration: InputDecoration(
                          labelText: 'x${i + 1}(t)',
                          border: OutlineInputBorder()),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StepThree extends StatelessWidget {
  const StepThree(
      {this.piecewiseFunction,
      this.limitersRangeValues,
      this.selectorRangeValues,
      this.onRangeValuesChanged,
      this.changeLimiters,
      this.maxY,
      this.chartData});
  final PiecewiseFunction piecewiseFunction;
  final RangeValues limitersRangeValues, selectorRangeValues;
  final ValueChanged<RangeValues> onRangeValuesChanged;
  final Function changeLimiters;
  final List<FlSpot> chartData;
  final double maxY;
  @override
  Widget build(BuildContext context) {
    final _language = getLocationCode(context);
    List<FlSpot> filteredData = chartData
        .where((value) =>
            value.x <= selectorRangeValues.end &&
            value.x >= selectorRangeValues.start)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 2,
          clipBehavior: Clip.hardEdge,
          child: TeXView(
            child: TeXViewDocument(
              windowHintText(
                  piecewiseFunction.pieces.map((piece) => piece.tex).toList(),
                  piecewiseFunction.domainValues
                      .map((discontinuity) => discontinuity.toStringAsFixed(2))
                      .toList(),
                  _language),
            ),
            renderingEngine: TeXViewRenderingEngine.mathjax(),
            loadingWidgetBuilder: (context) => TexLoadingWidget(height: 250),
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
                  kWindowingText[_language],
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              Card(
                elevation: 2,
                clipBehavior: Clip.hardEdge,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    extraLinesData: ExtraLinesData(horizontalLines: [
                      HorizontalLine(
                          y: 0, strokeWidth: 0.5, color: Colors.black54)
                    ]),
                    maxY: maxY,
                    minY: -maxY,
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false
                        //bottomTitles:
                        //   SideTitles(showTitles: true, getTitles: _xGenerator),
                        ),
                    lineTouchData: LineTouchData(enabled: false),
                    lineBarsData: [
                      LineChartBarData(
                          spots: chartData,
                          //     isCurved: true,
                          //    curveSmoothness: 0,
                          //    preventCurveOverShooting: true,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          colors: [Colors.blueGrey]),
                      if (filteredData.isNotEmpty)
                        LineChartBarData(
                            spots: filteredData,
                            //     isCurved: true,
                            //    curveSmoothness: 0,
                            //    preventCurveOverShooting: true,
                            barWidth: 5,
                            dotData: FlDotData(show: false),
                            colors: [Colors.black]),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(selectorRangeValues.start.toStringAsFixed(2) + 's'),
                    Text(selectorRangeValues.end.toStringAsFixed(2) + 's')
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: RangeSlider(
                  max: limitersRangeValues.end,
                  min: limitersRangeValues.start,
                  inactiveColor: Colors.blueGrey,
                  activeColor: Theme.of(context).accentColor,
                  // divisions: 20,
                  values: selectorRangeValues,
                  onChanged: onRangeValuesChanged,
                ),
              ),
              FlatButton(
                child: Text(kChangeBoundsText[_language]),
                onPressed: changeLimiters,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
