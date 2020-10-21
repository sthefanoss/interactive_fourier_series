import 'dart:math';

import 'package:function_tree/function_tree.dart';
import 'package:ifs/math/linear_space.dart';

class PiecewiseFunction {
  final List<double> discontinuities;
  final List<SingleVariableFunction> expressions;

  const PiecewiseFunction({
    this.discontinuities = const [],
    this.expressions,
  });

  PiecewiseFunction.fromString({
    this.discontinuities = const [],
    List<String> expressionsAsString,
  }) : expressions = expressionsAsString
            .map((expressionAsString) =>
                expressionAsString.toSingleVariableFunction('t'))
            .toList();

  PiecewiseFunction copyWith({
    List<double> discontinuities,
    List<SingleVariableFunction> expressions,
  }) {
    return PiecewiseFunction(
      discontinuities: discontinuities ?? this.discontinuities,
      expressions: expressions ?? this.expressions,
    );
  }

  Point<double> call(double x) {
    int index;
    for (index = 0;
        index < discontinuities.length && x > discontinuities[index];
        index++);
    return Point<double>(x, expressions[index].call(x).toDouble());
  }

  List<Point<double>> callFromLinearSpace(LinearSpace space) {
    return space.data.map<Point<double>>(call).toList();
  }
}
