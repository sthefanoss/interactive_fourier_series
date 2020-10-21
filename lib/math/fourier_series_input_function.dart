import 'dart:math';

import 'package:function_tree/function_tree.dart';
import 'package:ifs/math/piecewise_function.dart';

class FourierSeriesInputFunction extends PiecewiseFunction {
  final double start;
  final double end;
  final String name;

  const FourierSeriesInputFunction({
    this.start,
    this.end,
    this.name,
    List<double> discontinuities = const [],
    List<SingleVariableFunction> expressions,
  }) : super(
          discontinuities: discontinuities,
          expressions: expressions,
        );

  FourierSeriesInputFunction.fromString({
    this.start,
    this.end,
    this.name,
    List<double> discontinuities = const [],
    List<String> expressionsAsString,
  }) : super.fromString(
          discontinuities: discontinuities,
          expressionsAsString: expressionsAsString,
        );

  static List<FourierSeriesInputFunction> examples = [
    FourierSeriesInputFunction.fromString(
      start: -pi,
      end: pi,
      name: "Sine",
      expressionsAsString: ['sin(t)'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -pi,
      end: pi,
      name: "Cosine",
      expressionsAsString: ['cos(t)'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -20 * pi,
      end: 20 * pi,
      name: "Sinc",
      expressionsAsString: ['sin(t)/t'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -20 * pi,
      end: 20 * pi,
      name: "Squared Sinc",
      expressionsAsString: ['(sin(t)/t)^2'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -pi,
      end: pi,
      name: "Signal",
      discontinuities: [0],
      expressionsAsString: ['-1', '1'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -pi,
      end: pi,
      name: "Step",
      discontinuities: [0],
      expressionsAsString: ['0', '1'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -pi,
      end: pi,
      name: "Rectangular",
      discontinuities: [-0.5, 0.5],
      expressionsAsString: ['0', '1', '0'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -pi,
      end: pi,
      name: "Triangular",
      discontinuities: [-1, 0, 1],
      expressionsAsString: ['0', '1+t', '1-t', '0'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -pi,
      end: pi,
      name: "Half Wave Sine",
      discontinuities: [0],
      expressionsAsString: ['0 ', 'sin(t)'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -pi,
      end: pi,
      name: "Full Wave Sine",
      discontinuities: [0],
      expressionsAsString: ['-sin(t)', 'sin(t)'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -pi,
      end: pi,
      name: "Half Ramp",
      discontinuities: [0],
      expressionsAsString: ['0', 't'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -pi,
      end: pi,
      name: "Ramp",
      expressionsAsString: ['t'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -pi,
      end: pi,
      name: "Half Parabola",
      discontinuities: [0],
      expressionsAsString: ['0', 't^2'],
    ),
    FourierSeriesInputFunction.fromString(
      start: -pi,
      end: pi,
      name: "Parabola",
      expressionsAsString: ['t^2'],
    ),
  ];
}
