import 'dart:math';

import 'package:ifs/math/linear_space.dart';
import 'package:ifs/math/piecewise_function.dart';

class FourierSeries {
  final double period;
  final double frequency;
  final double angularFrequency;
  final double rootMeanSquare;
  final double higherAmplitude;
  final List<double> bCoefficients;
  final List<double> aCoefficients;
  final List<double> magnitudeCoefficients;
  final List<double> phaseCoefficients;

  const FourierSeries({
    this.period,
    this.rootMeanSquare,
    this.higherAmplitude,
    this.bCoefficients,
    this.aCoefficients,
    this.magnitudeCoefficients,
    this.phaseCoefficients,
  })  : frequency = 1 / period,
        angularFrequency = 2 * pi / period;

  factory FourierSeries.evaluate(
    PiecewiseFunction function, {
    LinearSpace representationSpace,
    int numberOfTerms = 20,
  }) {
    final functionPoints = function.callFromLinearSpace(
      representationSpace,
    );

    final coefficients = _evaluateCoefficients(
      numberOfTerms: numberOfTerms,
      functionPoints: functionPoints,
    );

    final rootMeanSquare = _evaluateRootMeanSquare(
      amplitudeCoefficients: coefficients[2],
    );

    final higherAmplitude = _evaluateHigherAmplitude(
      amplitudeCoefficients: coefficients[2],
    );

    return FourierSeries(
      bCoefficients: coefficients[0],
      aCoefficients: coefficients[1],
      magnitudeCoefficients: coefficients[2],
      phaseCoefficients: coefficients[3],
      period: representationSpace.end - representationSpace.start,
      rootMeanSquare: rootMeanSquare,
      higherAmplitude: higherAmplitude,
    );
  }

  static List<List<double>> _evaluateCoefficients({
    int numberOfTerms,
    List<Point<double>> functionPoints,
  }) {
    final bCoefficients = List<double>(numberOfTerms + 1);
    final aCoefficients = List<double>(numberOfTerms + 1);
    final amplitudeCoefficients = List<double>(numberOfTerms + 1);
    final phaseCoefficients = List<double>(numberOfTerms + 1);

    ///numeric integration for sine and cosine coefficients evaluation
    final double dx = functionPoints[1].x - functionPoints[0].x;
    final double period = (functionPoints.last.x - functionPoints.first.x);
    for (int index = 0; index <= numberOfTerms; index++) {
      double nPiL = index * pi * 2 / period;
      aCoefficients[index] = 0;
      bCoefficients[index] = 0;

      functionPoints.forEach((point) {
        double arc = nPiL * point.x;
        aCoefficients[index] += point.y * cos(arc);
        bCoefficients[index] += point.y * sin(arc);
      });

      aCoefficients[index] *= 2 * dx / period;
      bCoefficients[index] *= 2 * dx / period;
    }

    ///amplitude and phase coefficients evaluation
    for (int index = 0; index <= numberOfTerms; index++) {
      amplitudeCoefficients[index] = sqrt(
        aCoefficients[index] * aCoefficients[index] +
            bCoefficients[index] * bCoefficients[index],
      );
      phaseCoefficients[index] =
          atan2(bCoefficients[index], aCoefficients[index]);
    }

    return [
      bCoefficients,
      aCoefficients,
      amplitudeCoefficients,
      phaseCoefficients
    ];
  }

  static double _evaluateRootMeanSquare({
    List<double> amplitudeCoefficients,
  }) {
    ///functional amplitude sum
    double amplitudeSum = amplitudeCoefficients.fold(
      0,
      (previousValue, element) {
        return previousValue + element;
      },
    );
    return sqrt(amplitudeSum / 2);
  }

  static double _evaluateHigherAmplitude({
    List<double> amplitudeCoefficients,
  }) {
    return amplitudeCoefficients.fold(
        0,
        (previousValue, element) => element.abs() > previousValue.abs()
            ? element.abs()
            : previousValue.abs());
  }

  Point<double> call(double x, {int lowerCutoffIndex, int higherCutoffIndex}) {
    lowerCutoffIndex = lowerCutoffIndex ?? 0;
    higherCutoffIndex = higherCutoffIndex ?? magnitudeCoefficients.length - 1;
    double sum = 0;
    double arc = angularFrequency * x;
    if (lowerCutoffIndex == 0) {
      sum = aCoefficients[0] / 2;
      lowerCutoffIndex++;
    }
    for (int index = lowerCutoffIndex; index <= higherCutoffIndex; index++)
      sum += aCoefficients[index] * cos(index * arc) +
          bCoefficients[index] * sin(index * arc);
    return Point(x, sum);
  }

  List<Point<double>> callFromLinearSpace({
    LinearSpace space,
    int lowerCutoffIndex,
    int higherCutoffIndex,
  }) {
    return space.data
        .map<Point<double>>(
          (value) => call(
            value,
            lowerCutoffIndex: lowerCutoffIndex,
            higherCutoffIndex: higherCutoffIndex,
          ),
        )
        .toList();
  }
}
