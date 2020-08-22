import 'dart:math';
import 'package:function_tree/function_tree.dart' as tree;
import 'package:ifs/math/linear_space.dart';

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

  List<Point<double>> callFromLinearSpace(LinearSpace space) {
    return space.data.map<Point<double>>(call).toList();
  }
}
