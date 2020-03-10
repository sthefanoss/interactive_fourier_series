import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tex/flutter_tex.dart';
import '../constants/regular_expressions.dart';
import './../widgets/radio_text.dart';
import 'dart:math';
import 'help.dart';
import '../constants/strings.dart';
import 'package:function_tree/function_tree.dart' as tree;
import 'package:fl_chart/fl_chart.dart' as chart;
import '../math/math.dart';
import '../widgets/custom_numeric_text_form_field.dart';
import '../widgets/text_loading_widget.dart';

enum WindowMode { Period, Arbitrary }

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  List<TextEditingController> _descontControllers = [];
  List<TextEditingController> _funcControllers = [TextEditingController()];
  PiecewiseFunction _piecewiseFunction = PiecewiseFunction();
  TrigonometricFourierSeries _trigonometricFourierSeries;
  double _period, _start, _end, _maxY;
  bool _gotResults = false,
      _showAn = true,
      _showBn = true,
      _show5 = true,
      _show10 = true,
      _show15 = true,
      _showMax = true,
      _showF = true,
      _showT = true;
  RangeValues _rangeValues = RangeValues(0, 20);
  List<chart.FlSpot> _plotPoints, _seriePoints, _5, _10, _15, _filtered;
  final _periodController = TextEditingController(text: '1'),
      _startController = TextEditingController(text: '-0.5'),
      _endController = TextEditingController(text: '0.5');
  int step = 0, sents = 1;
  final _descontKey = GlobalKey<FormState>(), _funcKey = GlobalKey<FormState>();
  WindowMode _windowMode = WindowMode.Period;

  void _setWindowMode(WindowMode value) {
    setState(() {
      _windowMode = value;
    });
  }

  void _setSents(int value) {
    setState(() {
      sents = value;
      _piecewiseFunction.pieces = List<tree.SingleVariableFunction>(sents);
      _piecewiseFunction.domainValues = List<double>(sents - 1);

      if (sents == 1) {
        _descontControllers = null;
        _funcControllers = [TextEditingController(text: '')];
      } else {
        _descontControllers = [
          for (int i = 0; i < sents - 1; i++) TextEditingController(text: '')
        ];
        _funcControllers = [
          for (int i = 0; i < sents; i++) TextEditingController(text: '')
        ];
      }
    });
  }

  @override
  void initState() {
    _setSents(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(kAppName['pt']),
            centerTitle: true,
            actions: <Widget>[
              FlatButton.icon(
                icon: Container(),
                textColor: Colors.white,
                label: Text('Ajuda'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HelpPage()));
                },
              )
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  child: Text('Voltar'),
                  onPressed: _gotResults
                      ? () {
                          setState(() {
                            _gotResults = false;
                          });
                        }
                      : step != 0 ? _onStepCancel : null,
                ),
                FlatButton(
                  child: Text(
                    'Avançar',
                  ),
                  onPressed: !_gotResults ? _onStepContinue : null,
                ),
              ],
            ),
          ),
          body: !_gotResults
              ? Stepper(
                  currentStep: step,
                  type: StepperType.horizontal,
                  onStepContinue: null,
                  onStepCancel: null,
                  controlsBuilder: (BuildContext context,
                          {VoidCallback onStepContinue,
                          VoidCallback onStepCancel}) =>
                      Container(),
                  steps: [
                    Step(
                      title: Text(step == 0 ? 'Sentenças' : ''),
                      state: getState(0),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            child: TeXView(
                              teXHTML: kDescontinuidadesTex,
                              renderingEngine: RenderingEngine.MathJax,
                              loadingWidget: TexLoadingWidget(
                                height: (200 + sents * 15).toDouble(),
                              ),
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Número de Sentenças',
                              style: Theme.of(context).textTheme.title,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              for (int i = 1; i <= 5; i++)
                                RadioText<int>(
                                  value: i,
                                  text: '$i',
                                  groupValue: sents,
                                  onChanged: _setSents,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: Text(step == 1 ? 'Descontinuidades' : ''),
                      state: getState(1),
                      content: step != 1
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                TeXView(
                                  teXHTML: _functionGenerator1(sents),
                                  renderingEngine: RenderingEngine.MathJax,
                                  loadingWidget: TexLoadingWidget(),
                                ),
                                Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Valores das Descontinuidades',
                                    style: Theme.of(context).textTheme.title,
                                  ),
                                ),
                                Form(
                                  key: _descontKey,
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    children: <Widget>[
                                      for (int i = 0;
                                          i < _descontControllers.length;
                                          i++)
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          child: TextFormField(
                                            controller: _descontControllers[i],
                                            validator: (value) {
                                              try {
                                                _piecewiseFunction
                                                        .domainValues[i] =
                                                    value
                                                        .interpret()
                                                        .toDouble();
                                                return null;
                                              } catch (e) {
                                                print(e);
                                                return "Expressão Inválida";
                                              }
                                            },
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
                    Step(
                      title: Text(step == 2 ? 'Expressões' : ''),
                      state: getState(2),
                      content: step != 2
                          ? Container()
                          : Form(
                              key: _funcKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  TeXView(
                                    teXHTML: _functionGenerator2(
                                        sents,
                                        sents == 1
                                            ? null
                                            : _piecewiseFunction.domainValues
                                                .map((descss) =>
                                                    descss.toStringAsFixed(2))
                                                .toList()),
                                    renderingEngine: RenderingEngine.MathJax,
                                    loadingWidget: TexLoadingWidget(),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Expressões',
                                      style: Theme.of(context).textTheme.title,
                                    ),
                                  ),
                                  for (int i = 0;
                                      i < _funcControllers.length;
                                      i++)
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      child: TextFormField(
                                        controller: _funcControllers[i],
                                        validator: (value) {
                                          try {
                                            _piecewiseFunction.pieces[i] = value
                                                .toSingleVariableFunction('t');
                                            return null;
                                          } catch (e) {
                                            print("erro no interpretador:" +
                                                e.toString());
                                            return "Expressão de t Inválida";
                                          }
                                        },
                                        decoration: InputDecoration(
                                            labelText: 'f${i + 1}(t)',
                                            border: OutlineInputBorder()),
                                      ),
                                    ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Enjanelamento',
                                      style: Theme.of(context).textTheme.title,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      RadioText<WindowMode>(
                                        text: 'Período',
                                        value: WindowMode.Period,
                                        groupValue: _windowMode,
                                        onChanged: _setWindowMode,
                                      ),
                                      RadioText<WindowMode>(
                                        text: 'Limites Arbitrários',
                                        value: WindowMode.Arbitrary,
                                        groupValue: _windowMode,
                                        onChanged: _setWindowMode,
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    children: _windowMode == WindowMode.Period
                                        ? [
                                            CustomNumericTextFormField(
                                                labelText: 'Valor',
                                                controller: _periodController,
                                                validator: (value) {
                                                  try {
                                                    _period = value
                                                        .interpret()
                                                        .toDouble();
                                                    _start = -_period / 2;
                                                    _end = _period / 2;
                                                    return null;
                                                  } catch (e) {
                                                    print(e);
                                                    return "Expressão numérica Inválida";
                                                  }
                                                }),
                                          ]
                                        : [
                                            CustomNumericTextFormField(
                                                labelText: 'Início',
                                                controller: _startController,
                                                validator: (value) {
                                                  try {
                                                    _start = value
                                                        .interpret()
                                                        .toDouble();
                                                    return null;
                                                  } catch (e) {
                                                    print(e);
                                                    return "Expressão numérica Inválida";
                                                  }
                                                }),
                                            CustomNumericTextFormField(
                                                labelText: 'Fim',
                                                controller: _endController,
                                                validator: (value) {
                                                  try {
                                                    _end = value
                                                        .interpret()
                                                        .toDouble();
                                                    _period = null;
                                                    return null;
                                                  } catch (e) {
                                                    print(e);
                                                    return "Expressão numérica Inválida";
                                                  }
                                                }),
                                          ],
                                  ),
                                ],
                              ),
                            ),
                    )
                  ],
                )
              : ListView(
                  children: <Widget>[
                    TeXView(
                      teXHTML: _functionGenerator3(
                          sents,
                          _piecewiseFunction.domainValues
                              .map((v) => v.toStringAsFixed(2))
                              .toList(),
                          _piecewiseFunction.pieces.map((f) => f.tex).toList()),
                      renderingEngine: RenderingEngine.MathJax,
                      loadingWidget: TexLoadingWidget(
                        height: (200 + sents * 10).toDouble(),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Gráficos de f(t) e T(t)',
                        style: Theme.of(context).textTheme.title,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: chart.LineChart(chart.LineChartData(
                        titlesData: chart.FlTitlesData(
                            bottomTitles: chart.SideTitles(
                                showTitles: true, getTitles: _xGenerator)),
                        lineTouchData: chart.LineTouchData(enabled: false),
                        lineBarsData: [
                          chart.LineChartBarData(
                              spots: _seriePoints,
                              //     isCurved: true,
                              //    curveSmoothness: 0,
                              //    preventCurveOverShooting: true,
                              barWidth: 1,
                              show: _showT,
                              dotData: chart.FlDotData(show: false),
                              colors: [Theme.of(context).colorScheme.primary]),
                          chart.LineChartBarData(
                              //   isStrokeCapRound: true,
                              spots: _plotPoints,
                              show: _showF,
                              //   isCurved: true,
                              barWidth: 2,
                              dotData: chart.FlDotData(show: false),
                              colors: [Colors.orange.withOpacity(0.75)]),
                        ],
                        minY: -_maxY,
                        maxY: _maxY,
                      )),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Switch(
                          value: _showF,
                          activeColor: Colors.orange,
                          onChanged: (value) {
                            setState(() {
                              _showF = value;
                            });
                          },
                        ),
                        Text('f(t)'),
                        Switch(
                          value: _showT,
                          activeColor: Colors.blue,
                          onChanged: (value) {
                            setState(() {
                              _showT = value;
                            });
                          },
                        ),
                        Text('T(t)'),
                      ],
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Gráficos de T(t) e suas somas parciais',
                        style: Theme.of(context).textTheme.title,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: chart.LineChart(
                        chart.LineChartData(
                          titlesData: chart.FlTitlesData(
                              bottomTitles: chart.SideTitles(
                                  showTitles: true, getTitles: _xGenerator)),
                          lineTouchData: chart.LineTouchData(enabled: false),
                          lineBarsData: [
                            chart.LineChartBarData(
                                spots: _5,
                                show: _show5,
                                //     isCurved: true,
                                //    curveSmoothness: 0,
                                //    preventCurveOverShooting: true,
                                barWidth: 1,
                                dotData: chart.FlDotData(show: false),
                                colors: [Colors.blue]),
                            chart.LineChartBarData(
                                spots: _10,
                                show: _show10,
                                //     isCurved: true,
                                //    curveSmoothness: 0,
                                //    preventCurveOverShooting: true,
                                barWidth: 1,
                                dotData: chart.FlDotData(show: false),
                                colors: [Colors.green]),
                            chart.LineChartBarData(
                                spots: _15,
                                show: _show15,
                                //     isCurved: true,
                                //    curveSmoothness: 0,
                                //    preventCurveOverShooting: true,
                                barWidth: 1,
                                dotData: chart.FlDotData(show: false),
                                colors: [Colors.orange]),
                            chart.LineChartBarData(
                                spots: _seriePoints,
                                show: _showMax,
                                //     isCurved: true,
                                //    curveSmoothness: 0,
                                //    preventCurveOverShooting: true,
                                barWidth: 1,
                                dotData: chart.FlDotData(show: false),
                                colors: [Colors.red]),
                          ],
                          minY: -_maxY,
                          maxY: _maxY,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Switch(
                          value: _show5,
                          activeColor: Colors.blue,
                          onChanged: (value) {
                            setState(() {
                              _show5 = value;
                            });
                          },
                        ),
                        Text('5H'),
                        Switch(
                          value: _show10,
                          activeColor: Colors.green,
                          onChanged: (value) {
                            setState(() {
                              _show10 = value;
                            });
                          },
                        ),
                        Text('10H'),
                        Switch(
                          value: _show15,
                          activeColor: Colors.orange,
                          onChanged: (value) {
                            setState(() {
                              _show15 = value;
                            });
                          },
                        ),
                        Text('15H'),
                        Switch(
                          value: _showMax,
                          activeColor: Colors.red,
                          onChanged: (value) {
                            setState(() {
                              _showMax = value;
                            });
                          },
                        ),
                        Text('20H'),
                      ],
                    ),
                    Divider(),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Gráficos de T(t) filtrado',
                        style: Theme.of(context).textTheme.title,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: chart.LineChart(
                        chart.LineChartData(
                          titlesData: chart.FlTitlesData(
                              bottomTitles: chart.SideTitles(
                                  showTitles: true, getTitles: _xGenerator)),
                          lineTouchData: chart.LineTouchData(enabled: false),
                          lineBarsData: [
                            chart.LineChartBarData(
                                spots: _filtered,
                                //     isCurved: true,
                                //    curveSmoothness: 0,
                                //    preventCurveOverShooting: true,
                                barWidth: 1,
                                dotData: chart.FlDotData(show: false),
                                colors: [Colors.blue]),
                          ],
                          minY: -_maxY,
                          maxY: _maxY,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RangeSlider(
                        min: 0,
                        max: (_trigonometricFourierSeries.a.length - 1)
                            .toDouble(),
                        values: _rangeValues,
                        labels: RangeLabels(
                            _rangeValues.start.toStringAsFixed(0),
                            _rangeValues.end.toStringAsFixed(0)),
                        divisions: (_trigonometricFourierSeries.a.length - 1),
                        onChanged: (values) {
                          setState(() {
                            _rangeValues = values;
                            _filtered = List<chart.FlSpot>(_plotPoints.length);
                            int start = _rangeValues.start.toInt(),
                                end = _rangeValues.end.toInt();
                            for (int i = 0; i < _plotPoints.length; i++) {
                              _filtered[i] = chart.FlSpot(
                                  _plotPoints[i].x,
                                  _trigonometricFourierSeries.at(
                                      _plotPoints[i].x, end, start));
                            }
                          });
                        },
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Espectro de T(t)',
                        style: Theme.of(context).textTheme.title,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: chart.BarChart(
                        chart.BarChartData(
                            maxY: _trigonometricFourierSeries.maxTerm,
                            //   alignment: chart.BarChartAlignment.start,
                            titlesData: chart.FlTitlesData(
                              show: true,
                              bottomTitles: chart.SideTitles(
                                  showTitles: true,
                                  getTitles: (value) =>
                                      value.toStringAsFixed(0)),
                            ),
                            barTouchData: chart.BarTouchData(enabled: false),
                            barGroups: [
                              for (int i = 0;
                                  i < _trigonometricFourierSeries.a.length;
                                  i++)
                                chart.BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    chart.BarChartRodData(
                                      y: _showAn
                                          ? _trigonometricFourierSeries.a[i]
                                              .abs()
                                          : 0,
                                      color: Colors.blue.withOpacity(0.75),
                                      width: 6,
                                    ),
                                    chart.BarChartRodData(
                                        y: _showBn
                                            ? _trigonometricFourierSeries.b[i]
                                                .abs()
                                            : 0,
                                        color: Colors.red.withOpacity(0.75),
                                        width: 6)
                                  ],
                                  barsSpace: 0,
                                ),
                            ]),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Switch(
                          value: _showAn,
                          activeColor: Colors.blue,
                          onChanged: (value) {
                            setState(() {
                              _showAn = value;
                            });
                          },
                        ),
                        Text('|An|'),
                        Switch(
                          value: _showBn,
                          activeColor: Colors.red,
                          onChanged: (value) {
                            setState(() {
                              _showBn = value;
                            });
                          },
                        ),
                        Text('|Bn|'),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _functionGenerator1(int sentences) {
    String textExpression =
        r""" Entre com os valores de \(t_n\) das <B>descontinuidades</B> de \(f(t)\) 
  $$ f(t) = \left\{
	\begin{array}{ll} f_1(t)  & \mbox{se } t \leq t_1 \\ """;
    for (int i = 1; i < sentences; i++)
      if (i == sentences - 1)
        textExpression += r""" f_""" +
            (i + 1).toString() +
            r"""(t)  & \mbox{se } t > t_""" +
            i.toString() +
            r""" \end{array} \right. $$
          <p><B>Detalhes:</B>
          <p>\(\cdot{}\)Os valores devem estar em ordem crescente;        
          <p>\(\cdot{}\)Expressões numéricas são válidas, como: pi^2, sqrt(2), e/2, etc.$$\pi^2 \quad \sqrt{2} \quad \frac{e}{2}$$""";
      else
        textExpression += r""" f_""" +
            (i + 1).toString() +
            r"""(t)  & \mbox{se } t_""" +
            i.toString() +
            r"""< t \leq t_""" +
            (i + 1).toString() +
            r""" \\ """;
    return textExpression;
  }

  String _functionGenerator2(int sentences, [List<String> times]) {
    if (sentences == 1)
      return r""" Entre com a expressão de \(f(t)\).
       <p><B>Detalhe:</B>
          <p>\(\cdot{}\)A função não pode resultar em \(\pm\) \(\infty\) 
          ou em expressões complexas no período que representará \(T(t)\).
          <p>Depois escolha o período \(T_0\) que servirá para calcular os termos \(a_n\) e \(b_n\)
           de -\(T_0 \over 2\) a \(T_0 \over 2\). Ou escolha arbitrariamente tais limites.""";
    String textExpression = r""" Entre com as expressões de \(f(t)\).
  $$ f(t) = \left\{
	\begin{array}{ll} f_1(t)  & \mbox{se } t \leq """ +
        times[0] +
        r""" \\ """;
    for (int i = 1; i < sentences; i++)
      if (i == sentences - 1)
        textExpression += r""" f_""" +
            (i + 1).toString() +
            r"""(t)  & \mbox{se } t > """ +
            times[i - 1] +
            r""" \end{array} \right. $$
          <p><B>Detalhe:</B>
          <p>\(\cdot{}\)A função não pode resultar em \(\pm\) \(\infty\) 
          ou em expressões complexas no período que representará \(T(t)\).
          <p>Depois escolha o período \(T_0\) que servirá para calcular os termos \(a_n\) e \(b_n\)
           de -\(T_0 \over 2\) a \(T_0 \over 2\). Ou escolha arbitrariamente tais limites.""";
      else
        textExpression += r""" f_""" +
            (i + 1).toString() +
            r"""(t)  & \mbox{se } """ +
            times[i - 1] +
            r"""< t \leq """ +
            times[i] +
            r""" \\ """;
    return textExpression;
  }

  String _functionGenerator3(int sentences,
      [List<String> times, List<String> funcs]) {
    String start = r"""<B> Função original \(f(t)\)</B>""";
    String end = r""" <p> <B>Função da série \(T(t)\)</B>:
    $$T(t) \approx f(t) \quad \forall t \in [ """ +
        _start.toStringAsFixed(2) +
        r""",""" +
        _end.toStringAsFixed(2) +
        r"""]$$$$T_0=""" +
        _period.toStringAsFixed(2) +
        r"""s\qquad \omega_0=""" +
        (2 * pi / _period).toStringAsFixed(2) +
        r"""rad/s \quad T_{rms,20}= """ +
        _trigonometricFourierSeries.rms.toStringAsFixed(3) +
        r"""$$
     """;
    String function;
    if (sentences == 1)
      function = r"""$$f(t)=""" + funcs[0] + r"""$$""";
    else {
      function = r"""$$ f(t) = \left\{
    \begin{array}{ll}  """ +
          funcs[0] +
          r"""  & \mbox{se } t \leq """ +
          times[0] +
          r""" \\ """;
      for (int i = 1; i < sentences; i++)
        if (i == sentences - 1)
          function += funcs[i] +
              r"""  & \mbox{se } t > """ +
              times[i - 1] +
              r""" \end{array} \right. $$""";
        else
          function += funcs[i] +
              r"""  & \mbox{se } """ +
              times[i - 1] +
              r"""< t \leq """ +
              times[i] +
              r""" \\ """;
    }
    return start + function + end;
  }

  void _onStepContinue() {
    setState(() {
      switch (step) {
        case 0:
          if (sents == 1)
            step = 2;
          else
            step = 1;
          break;
        case 1:
          if (_descontKey.currentState.validate()) {
            for (int i = 0; i < _descontControllers.length; i++)
              for (int j = i + 1; j < _descontControllers.length; j++)
                if (_piecewiseFunction.domainValues[i] >
                    _piecewiseFunction.domainValues[j]) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: Text('Ordem Inválida'),
                            content: Text(
                                'As descontinuidades não estão em ordem crescente!'),
                            actions: <Widget>[
                              FlatButton(
                                  child: Text('Ok'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }),
                            ],
                          ));
                  return;
                }
            step++;
          }
          break;
        case 2:
          if (_funcKey.currentState.validate()) {
            if (_start < _end) {
              int numberOfPoints = 1024;
              _plotPoints = List<chart.FlSpot>(numberOfPoints);
              if (_period == null) {
                _period = (_end - _start);
                print("GRITA");
              }
              double meanPoint = (_start + _end) / 2,
                  chartStart = meanPoint - _period * 1.5;
              double dt = (3 * _period) / (numberOfPoints - 1);
              for (int i = 0; i < numberOfPoints; i++) {
                double t = chartStart + dt * i, y = _piecewiseFunction.at(t);
                _plotPoints[i] = chart.FlSpot(t, y);
              }
              _trigonometricFourierSeries = TrigonometricFourierSeries(
                  _piecewiseFunction,
                  start: _start,
                  end: _end);
              _seriePoints = List<chart.FlSpot>(numberOfPoints);
              _5 = List<chart.FlSpot>(numberOfPoints);
              _10 = List<chart.FlSpot>(numberOfPoints);
              _15 = List<chart.FlSpot>(numberOfPoints);
              _filtered = List<chart.FlSpot>(numberOfPoints);
              for (int i = 0; i < numberOfPoints; i++) {
                _seriePoints[i] = chart.FlSpot(_plotPoints[i].x,
                    _trigonometricFourierSeries.at(_plotPoints[i].x));
                _5[i] = chart.FlSpot(_plotPoints[i].x,
                    _trigonometricFourierSeries.at(_plotPoints[i].x, 5));
                _10[i] = chart.FlSpot(_plotPoints[i].x,
                    _trigonometricFourierSeries.at(_plotPoints[i].x, 10));
                _15[i] = chart.FlSpot(_plotPoints[i].x,
                    _trigonometricFourierSeries.at(_plotPoints[i].x, 15));
                _filtered[i] = chart.FlSpot(
                    _plotPoints[i].x,
                    _trigonometricFourierSeries.at(_plotPoints[i].x,
                        _rangeValues.end.round(), _rangeValues.start.round()));
              }
              //find max |Y|
              _maxY = 0;
              for (chart.FlSpot yValue in _seriePoints) {
                double absY = yValue.y.abs();
                if (absY > _maxY) _maxY = absY;
              }
              _maxY = (1.2 * _maxY).ceilToDouble();
              List<chart.FlSpot> _newBoundedChart = [];
              for (chart.FlSpot spot in _plotPoints)
                if (spot.y.abs() < _maxY) _newBoundedChart.add(spot);
              _plotPoints = _newBoundedChart;
              _gotResults = true;
            } else
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: Text('Ordem Inválida'),
                        content: Text('O início deve ser antes do fim!'),
                        actions: <Widget>[
                          FlatButton(
                              child: Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ],
                      ));
          }
          break;
      }
    });
  }

  void _onStepCancel() {
    setState(() {
      switch (step) {
        case 1:
          step = 0;
          break;
        case 2:
          if (sents == 1)
            step = 0;
          else
            step = 1;
          break;
        case 3:
          step--;
          break;
      }
    });
  }

  StepState getState(int thisStep) => thisStep == step
      ? StepState.editing
      : thisStep < step ? StepState.complete : StepState.indexed;

  String _xGenerator(double value) =>
      ((value) % (_trigonometricFourierSeries.period / 4)).abs() /
                  _trigonometricFourierSeries.period <
              0.05
          ? value.toStringAsFixed(2)
          : '';
}
