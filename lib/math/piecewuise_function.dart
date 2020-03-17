import 'package:function_tree/function_tree.dart' as tree;

class PiecewiseFunction {
  List<num> domainValues;
  List<tree.SingleVariableFunction> pieces;

  double at(double domain) {
    int i;
    for (i = 0; i < domainValues.length && domain > domainValues[i]; i++);
    return pieces[i].call(domain).toDouble();
  }
}
