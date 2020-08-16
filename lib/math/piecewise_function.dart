import 'dart:math';
import 'package:function_tree/function_tree.dart' as tree;

class PiecewiseFunction {
  final List<double> discontinuities;
  final List<tree.SingleVariableFunction> expressions;

  const PiecewiseFunction({
    this.discontinuities,
    this.expressions,
  });

  Point<double> call(double x) {
    int index;
    for (index = 0;
        index < discontinuities.length && x > discontinuities[index];
        index++);
    return Point<double>(x, expressions[index].call(x).toDouble());
  }

  List<Point<double>> discretize({
    double start,
    double end,
    int length,
  }) {
    final functionCalls = List<Point<double>>(length);
    final double dx = (end - start) / (length - 1);

    for (int index = 0; index < length; index++) {
      double x = start + dx * index;
      functionCalls[index] = call(x);
    }
    return functionCalls;
  }
}
