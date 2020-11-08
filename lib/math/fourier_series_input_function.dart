import 'dart:math';

import 'package:ifs/math/piecewise_function.dart';

class FourierSeriesInputFunction extends PiecewiseFunction {
  final double start;
  final double end;
  final Map<String, String> names;

  FourierSeriesInputFunction({
    this.start,
    this.end,
    this.names,
    List<double> discontinuities = const [],
    List<String> expressionsAsString,
  }) : super(
          discontinuities: discontinuities,
          expressionsAsString: expressionsAsString,
        );

  static List<FourierSeriesInputFunction> examples = [
    FourierSeriesInputFunction(
      start: -pi,
      end: pi,
      names: {
        'pt': 'Seno',
        'en': 'Sine',
      },
      expressionsAsString: ['sin(t)'],
    ),
    FourierSeriesInputFunction(
      start: -pi,
      end: pi,
      names: {
        'pt': 'Cosseno',
        'en': 'Cosine',
      },
      expressionsAsString: ['cos(t)'],
    ),
    FourierSeriesInputFunction(
      start: -20 * pi,
      end: 20 * pi,
      names: {
        'pt': 'Sinc',
        'en': 'Sinc',
      },
      expressionsAsString: ['sin(t)/t'],
    ),
    FourierSeriesInputFunction(
      start: -20 * pi,
      end: 20 * pi,
      names: {
        'pt': 'Sinc ao Quadrado',
        'en': 'Squared Sinc',
      },
      expressionsAsString: ['(sin(t)/t)^2'],
    ),
    FourierSeriesInputFunction(
      start: -pi,
      end: pi,
      names: {
        'pt': 'Função Sinal',
        'en': 'Signal Function',
      },
      discontinuities: [0],
      expressionsAsString: ['-1', '1'],
    ),
    FourierSeriesInputFunction(
      start: -pi,
      end: pi,
      names: {
        'pt': 'Degrau Unitário',
        'en': 'Step Function',
      },
      discontinuities: [0],
      expressionsAsString: ['0', '1'],
    ),
    FourierSeriesInputFunction(
      start: -1,
      end: 1,
      names: {
        'pt': 'Função Retangular',
        'en': 'Rectangular Function',
      },
      discontinuities: [-0.5, 0.5],
      expressionsAsString: ['0', '1', '0'],
    ),
    FourierSeriesInputFunction(
      start: -1,
      end: 1,
      names: {
        'pt': 'Função Triangular',
        'en': 'Triangular Function',
      },
      discontinuities: [-1, 0, 1],
      expressionsAsString: ['0', '1+t', '1-t', '0'],
    ),
    FourierSeriesInputFunction(
      start: -pi,
      end: pi,
      names: {
        'pt': 'Seno de Meia Onda',
        'en': 'Half Wave Sine',
      },
      discontinuities: [0],
      expressionsAsString: ['0 ', 'sin(t)'],
    ),
    FourierSeriesInputFunction(
      start: -pi,
      end: pi,
      names: {
        'pt': 'Seno de Onda Completa',
        'en': 'Full Wave Sine',
      },
      discontinuities: [0],
      expressionsAsString: ['-sin(t)', 'sin(t)'],
    ),
    FourierSeriesInputFunction(
      start: -pi,
      end: pi,
      names: {
        'pt': 'Rampa',
        'en': 'Ramp',
      },
      expressionsAsString: ['t'],
    ),
    FourierSeriesInputFunction(
      start: -pi,
      end: pi,
      names: {
        'pt': 'Parábola',
        'en': 'Parabola',
      },
      expressionsAsString: ['t^2'],
    ),
  ];
}
