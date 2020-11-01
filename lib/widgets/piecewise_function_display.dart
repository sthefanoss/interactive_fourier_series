import 'package:catex/catex.dart';
import 'package:flutter/material.dart';
import 'package:ifs/math/piecewise_function.dart';

class PiecewiseFunctionDisplay extends StatelessWidget {
  final PiecewiseFunction piecewiseFunction;
  static const double _partHeight = 24;
  PiecewiseFunctionDisplay(this.piecewiseFunction);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _partHeight * PiecewiseFunction.maxPieces,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CaTeX(r'f(t) = '),
          SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int index = 0;
                    index < piecewiseFunction.expressions.length;
                    index++)
                  Container(
                    height: _partHeight,
                    child: Row(
                      children: [
                        // Expanded(
                        //   flex: 3,
                        //   child: Align(
                        //     alignment: Alignment.centerRight,
                        //     child:
                        CaTeX(piecewiseFunction.expressionsAsString[index]),
                        //   ),
                        // ),
                        // Expanded(
                        //   flex: 3,
                        SizedBox(
                          width: 10,
                        ),
                        _buildDiscontinuityCaTeX(index),
                        // ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscontinuityCaTeX(int index) {
    if (piecewiseFunction.discontinuities.isEmpty) return Container();

    if (index == 0)
      return CaTeX(
          '\\text{, } t ≤ ${piecewiseFunction.discontinuities.first.toStringAsFixed(2)}');

    bool isLast = index == piecewiseFunction.expressions.length - 1;

    if (!isLast)
      return CaTeX(
          '\\text{, } ${piecewiseFunction.discontinuities[index - 1].toStringAsFixed(2)} < t ≤ ${piecewiseFunction.discontinuities[index].toStringAsFixed(2)}');

    return CaTeX(
        '\\text{, } t > ${piecewiseFunction.discontinuities.last.toStringAsFixed(2)}');
  }
}
