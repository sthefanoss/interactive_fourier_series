import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ifs/widgets/change_bounds_alert_dialog.dart';
import 'dart:math';
import 'package:function_tree/function_tree.dart' as tree;
import 'package:fl_chart/fl_chart.dart';
import '../math/piecewuise_function.dart';
import '../strings/constants.dart';
import '../widgets/calculator_steps.dart';

class CalculatorInputPage extends StatefulWidget {
  @override
  _CalculatorInputPageState createState() => _CalculatorInputPageState();
}

class _CalculatorInputPageState extends State<CalculatorInputPage> {
  ///general
  final PiecewiseFunction _piecewiseFunction = PiecewiseFunction();
  int _stepIndex = 0;
  bool _init = true;
  String _language;

  ///step zero
  int _piecesCount = 1, _lastPiecesCount = 0;

  ///step one
  List<TextEditingController> _discontinuitiesControllers = [];
  final _formOneKey = GlobalKey<FormState>();

  ///step two
  List<TextEditingController> _piecesControllers = [TextEditingController()];
  final _formTwoKey = GlobalKey<FormState>();

  ///step tree
  final List<TextEditingController> _windowLimitersControllers = [
    TextEditingController(text: '-pi/2'),
    TextEditingController(text: 'pi/2'),
  ];
  RangeValues _boundsRangeValues = RangeValues(-pi / 2, pi / 2);
  RangeValues _selectorRangeValues = RangeValues(-pi / 2, pi / 2);
  List<FlSpot> _chartData;
  double _maxY;

  @override
  void didChangeDependencies() {
    if (_init) {
      _language = getLocationCode(context);
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
        title: Text(kCalculatorInputName[_language]),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
              child: Text(kBackText[_language]),
              onPressed: _stepIndex != 0 ? _onStepCancel : null,
            ),
            FlatButton(
              child: Text(
                kForwardText[_language],
              ),
              onPressed: _onStepContinue,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stepper(
          currentStep: _stepIndex,
          type: StepperType.horizontal,
          onStepContinue: null,
          onStepCancel: null,
          controlsBuilder: (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) =>
              Container(),
          steps: [
            customStep(
                title: kPiecesNumberText[_language],
                stepIndex: 0,
                stepGroup: _stepIndex,
                content: StepZero(
                  onChanged: (value) => setState(() {
                    _piecesCount = value;
                  }),
                  expressionsCount: _piecesCount,
                )),
            customStep(
              title: kDiscontinuitiesText[_language],
              stepIndex: 1,
              stepGroup: _stepIndex,
              content: StepOne(
                expressionsCount: _piecesCount,
                formOneKey: _formOneKey,
                formOneTextControllers: _discontinuitiesControllers,
                validator: (value, index) {
                  try {
                    _piecewiseFunction.domainValues[index] =
                        value.interpret().toDouble();
                    return null;
                  } catch (e) {
                    print(e);
                    return kInvalidExpressionText[_language];
                  }
                },
              ),
            ),
            customStep(
                title: kPiecesOfFtText[_language],
                stepIndex: 2,
                stepGroup: _stepIndex,
                content: StepTwo(
                  formTwoKey: _formTwoKey,
                  validator: (value, index) {
                    try {
                      _piecewiseFunction.pieces[index] =
                          value.toSingleVariableFunction('t');
                      return null;
                    } catch (e) {
                      return kInvalidTExpressionText[_language];
                    }
                  },
                  domainValues: _piecewiseFunction.domainValues,
                  formTwoTextControllers: _piecesControllers,
                )),
            customStep(
                title: kWindowingText[_language],
                stepIndex: 3,
                stepGroup: _stepIndex,
                content: StepThree(
                  maxY: _maxY,
                  chartData: _chartData,
                  changeLimiters: _changeBounds,
                  limitersRangeValues: _boundsRangeValues,
                  selectorRangeValues: _selectorRangeValues,
                  onRangeValuesChanged: (values) => setState(() {
                    _selectorRangeValues = values;
                  }),
                  piecewiseFunction: _piecewiseFunction,
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _changeBounds() async {
    final key = GlobalKey<FormState>();
    final newValues = await showDialog<RangeValues>(
        context: context,
        builder: (BuildContext context) => ChangeBoundsAlertDialog(
              controllers: _windowLimitersControllers,
              formKey: key,
            ),
        barrierDismissible: false);
    if (newValues == null) return;
    _boundsRangeValues = newValues;
    _selectorRangeValues = newValues;
    setState(() {
      _updateChartData();
    });
  }

  void _setPiecesNumber(int value) {
    setState(() {
      _piecesCount = value;
      _piecewiseFunction.pieces =
          List<tree.SingleVariableFunction>(_piecesCount);
      _piecewiseFunction.domainValues = List<double>(_piecesCount - 1);

      if (_piecesCount == 1) {
        _discontinuitiesControllers = null;
        _piecesControllers = [TextEditingController(text: '')];
      } else {
        _discontinuitiesControllers = [
          for (int i = 0; i < _piecesCount - 1; i++)
            TextEditingController(text: '')
        ];
        _piecesControllers = [
          for (int i = 0; i < _piecesCount; i++) TextEditingController(text: '')
        ];
      }
    });
  }

  void _onStepContinue() {
    setState(() {
      switch (_stepIndex) {
        case 0:
          if (_lastPiecesCount != _piecesCount) {
            _setPiecesNumber(_piecesCount);
            _lastPiecesCount = _piecesCount;
          }
          if (_piecesCount == 1)
            _stepIndex = 2;
          else
            _stepIndex = 1;
          break;
        case 1:
          if (_formOneKey.currentState.validate()) {
            for (int i = 0; i < _discontinuitiesControllers.length; i++)
              for (int j = i + 1; j < _discontinuitiesControllers.length; j++)
                if (_piecewiseFunction.domainValues[i] >
                    _piecewiseFunction.domainValues[j]) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: Text(kInvalidOrderTitleText[_language]),
                            content: Text(kInvalidOrderContentText[_language]),
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
            _stepIndex++;
          }
          break;
        case 2:
          if (_formTwoKey.currentState.validate()) {
            _updateChartData();
            _stepIndex++;
          }
          break;
        case 3:
          Navigator.of(context).pushNamed('/calc-result', arguments: [
            _selectorRangeValues,
            _piecewiseFunction,
          ]);
          break;
      }
    });
  }

  void _updateChartData([int numberOfPoints = 1024]) {
    _maxY = 0;
    double dt = (_boundsRangeValues.end - _boundsRangeValues.start) /
        (numberOfPoints - 1);
    final newChartData = List<FlSpot>(numberOfPoints);
    for (int i = 0; i < numberOfPoints; i++) {
      double t = _boundsRangeValues.start + dt * i,
          y = _piecewiseFunction.at(t);
      newChartData[i] = FlSpot(t, y);
      if (y.abs() > _maxY) _maxY = y.abs();
    }
    _maxY = 1.25 * _maxY;
    _chartData = newChartData;
  }

  void _onStepCancel() {
    setState(() {
      switch (_stepIndex) {
        case 1:
          _stepIndex = 0;
          break;
        case 2:
          if (_piecesCount == 1)
            _stepIndex = 0;
          else
            _stepIndex = 1;
          break;
        case 3:
          _stepIndex--;
          break;
      }
    });
  }
}

Step customStep({int stepIndex, int stepGroup, Widget content, String title}) =>
    Step(
        title: Text(stepIndex == stepGroup ? title : ''),
        isActive: stepIndex == stepGroup,
        content: stepIndex == stepGroup ? content : Container(),
        state: stepIndex == stepGroup
            ? StepState.editing
            : stepIndex < stepGroup ? StepState.complete : StepState.indexed);
