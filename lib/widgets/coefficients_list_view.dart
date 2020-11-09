import 'package:catex/catex.dart';
import 'package:flutter/material.dart';
import 'package:ifs/math/fourier_series.dart';

class CoefficientsListView extends StatelessWidget {
  final FourierSeries trigonometricFourierSeries;

  CoefficientsListView(this.trigonometricFourierSeries);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: trigonometricFourierSeries.aCoefficients.length,
      itemBuilder: _buildTile,
    );
  }

  Widget _buildTile(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCaTeX(
              'A_{$index} = ${trigonometricFourierSeries.aCoefficients[index].toStringAsFixed(3)}',
              context),
          buildCaTeX(
              'B_{$index} = ${trigonometricFourierSeries.bCoefficients[index].toStringAsFixed(3)}',
              context),
          buildCaTeX(
              '\\sqrt{A^2_{$index}+B^2_{$index}} = ${trigonometricFourierSeries.magnitudeCoefficients[index].toStringAsFixed(3)}',
              context),
          buildCaTeX(
              '∠A_{$index},B_{$index}= ${trigonometricFourierSeries.phaseCoefficients[index].toStringAsFixed(3)} rad',
              context),
        ],
      ),
    );
  }

  Widget buildCaTeX(String expression, BuildContext context) {
    return DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.bodyText1,
      child: CaTeX(expression),
    );
  }
}
