import 'piecewuise_function.dart';
import 'dart:math';

class TrigonometricFourierSeries {
  TrigonometricFourierSeries(PiecewiseFunction function,
      {int numberOfTerms = 20,
      double start = -pi / 2,
      double end = pi / 2,
      int numberOfPoints = 100000})
      : a = List<double>(numberOfTerms + 1),
        b = List<double>(numberOfTerms + 1),
        c = List<double>(numberOfTerms + 1),
        omega = List<double>(numberOfTerms + 1),
        period = (end - start),
        mean = (end + start) / 2 {
    a[0] = 0;
    b[0] = 0;
    c[0] = 0;
    omega[0] = 0;
    double dt = period / (numberOfPoints - 1);
    final imageAndDomain = List<Point<double>>(numberOfPoints);
    for (int i = 0; i < numberOfPoints; i++) {
      double t = start + dt * i, y = function.at(t);
      imageAndDomain[i] = Point<double>(t, y);
      a[0] += y;
    }
    a[0] *= dt * 2 / period;
    c[0] = a[0].abs();
    omega[0] = atan2(0, a[0]);
    for (int n = 1; n <= numberOfTerms; n++) {
      double nPiL = n * pi * 2 / period;
      a[n] = 0;
      b[n] = 0;
      for (int i = 0; i < numberOfPoints; i++) {
        double arc = nPiL * imageAndDomain[i].x;
        a[n] += imageAndDomain[i].y * cos(arc);
        b[n] += imageAndDomain[i].y * sin(arc);
      }
      a[n] *= 2 * dt / period;
      b[n] *= 2 * dt / period;
      c[n] = sqrt(pow(a[n], 2) + pow(b[n], 2));
      omega[n] = atan2(b[n], a[n]);
    }
    _setMaxTerm();
    //  _setZeroes();
    _setRMS();
  }

  static TrigonometricFourierSeries make(List args) =>
      TrigonometricFourierSeries(args[0],
          start: args[1],
          end: args[2],
          numberOfTerms: 100,
          numberOfPoints: 100000);

  double at(double domain, [int end, int start = 0]) {
    if (end == null) end = a.length - 1;
    double sum = 0, kAngularFrequency = angularFrequency * domain;
    if (start == 0) {
      sum = a[0] / 2;
      start++;
    }
    for (int n = start; n <= end; n++)
      //sum += c[n] * cos(n * kAngularFrequency - omega[n]);
      sum +=
          a[n] * cos(n * kAngularFrequency) + b[n] * sin(n * kAngularFrequency);
    return sum;
  }

  final List<double> a, b, c, omega;
  final double period, mean;
  double get angularFrequency => 2 * pi / period;
  double get frequency => 1 / period;
  double _maxTerm, _rms;
  double get maxTerm => _maxTerm;
  double get rms => _rms;

  void _setMaxTerm() {
    double max = 0;
    for (int i = 0; i < c.length; i++) if (c[i].abs() > max) max = c[i];
    _maxTerm = max;
  }

  void _setRMS() {
    _rms = 0;
    for (int i = 1; i < a.length; i++) _rms += a[i] * a[i] + b[i] * b[i];
    _rms = sqrt(_rms / 2 + a[0] * a[0]);
  }

  void _setZeroes() {
    for (int i = 0; i < a.length; i++) if (c[i] / _maxTerm < 1E-3) omega[i] = 0;
  }
}
