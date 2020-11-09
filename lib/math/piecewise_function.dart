import 'dart:math';

import 'package:function_tree/function_tree.dart';
import 'package:ifs/math/linear_space.dart';

class PiecewiseFunction {
  static const maxPieces = 5;
  static const minPieces = 1;
  List<double> discontinuities;
  List<SingleVariableFunction> expressions;
  List<String> expressionsAsString;

  PiecewiseFunction({
    this.discontinuities = const [],
    this.expressionsAsString,
  }) : expressions = expressionsAsString
            .map((expressionAsString) =>
                expressionAsString.toSingleVariableFunction('t'))
            .toList();

  Point<double> call(double x) {
    int index;
    for (index = 0;
        index < discontinuities.length && x > discontinuities[index];
        index++);
    double result = expressions[index].call(x).toDouble();
    if (result.isInfinite || result.isNaN)
      throw 'The function image is either infinity or NaN!';
    return Point<double>(x, result);
  }

  List<Point<double>> callFromLinearSpace(LinearSpace space) {
    return space.data.map<Point<double>>(call).toList();
  }
}
