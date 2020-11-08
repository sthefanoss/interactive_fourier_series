import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class ChartInput {
  final List<Point> samples;
  final Color strokeColor;
  final double strokeWidth;
  final bool isDiscrete;

  ChartInput({
    @required this.samples,
    this.strokeWidth = 1,
    this.strokeColor = Colors.black54,
    this.isDiscrete = false,
  });
}

class ChartBoundaries {
  final double maxX;
  final double maxY;
  final double minX;
  final double minY;

  const ChartBoundaries({
    this.maxX,
    this.maxY,
    this.minX,
    this.minY,
  });

  ChartBoundaries.symmetric({
    double width,
    double height,
  })  : this.maxX = width != null ? width / 2 : null,
        this.maxY = height != null ? height / 2 : null,
        this.minX = width != null ? -width / 2 : null,
        this.minY = height != null ? -height / 2 : null;

  factory ChartBoundaries.fromChartInputList(List<ChartInput> input) {
    double maxX = -double.infinity;
    double maxY = -double.infinity;
    double minX = double.infinity;
    double minY = double.infinity;

    for (final element in input)
      for (final sample in element.samples) {
        if (sample.x > maxX) maxX = sample.x;
        if (sample.y > maxY) maxY = sample.y;
        if (sample.x < minX) minX = sample.x;
        if (sample.y < minY) minY = sample.y;
      }

    return ChartBoundaries(
      maxX: maxX,
      maxY: maxY,
      minX: minX,
      minY: minY,
    );
  }

  ChartBoundaries copyWith({
    double maxX,
    double maxY,
    double minX,
    double minY,
  }) =>
      ChartBoundaries(
        maxX: maxX ?? this.maxX,
        maxY: maxY ?? this.maxY,
        minX: minX ?? this.minX,
        minY: minY ?? this.minY,
      );

  String toString() {
    return 'ChartBoundaries(${minX.toStringAsFixed(2)}<x<${minX.toStringAsFixed(2)}' +
        ', ${minY.toStringAsFixed(2)}<y<${maxY.toStringAsFixed(2)})';
  }
}

class LineChart extends StatelessWidget {
  final List<ChartInput> input;
  final ChartBoundaries boundaries;
  final Size size;

  const LineChart._(
    this.input,
    this.boundaries,
    this.size,
  );

  factory LineChart({
    List<ChartInput> input,
    ChartBoundaries boundaries,
    Size size = const Size.fromHeight(200),
  }) {
    assert(input != null);

    if (boundaries?.maxX != null &&
        boundaries?.maxY != null &&
        boundaries?.minX != null &&
        boundaries?.minY != null) return LineChart._(input, boundaries, size);

    final inputBoundaries = ChartBoundaries.fromChartInputList(input);

    return LineChart._(
      input,
      boundaries == null
          ? inputBoundaries
          : inputBoundaries.copyWith(
              maxX: boundaries.maxX,
              maxY: boundaries.maxY,
              minX: boundaries.minX,
              minY: boundaries.minY,
            ),
      size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _LineChartPainter(
        input,
        boundaries,
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ChartInput> data;
  final ChartBoundaries options;
  final double xRange;
  final double yRange;
  final double xMean;
  final double yMean;
  final List<Paint> paints;

  Offset Function(Point) _pointNormalizer;

  _LineChartPainter(
    this.data,
    this.options,
  )   : xRange = options.maxX - options.minX,
        yRange = options.maxY - options.minY,
        xMean = options.maxX + options.minX,
        yMean = options.maxY + options.minY,
        paints = data.map(_generatePaint).toList();

  @override
  void paint(Canvas canvas, Size size) {
    double xCoefficient = size.width / xRange;
    double yCoefficient = -size.height / yRange;

    _pointNormalizer = (sample) => Offset(
          (sample.x - options.minX) * xCoefficient,
          (sample.y + options.minY) * yCoefficient,
        );

    canvas.drawLine(
      _pointNormalizer(Point(options.minX, 0)),
      _pointNormalizer(Point(options.maxX, 0)),
      Paint()
        ..color = Colors.black38
        ..strokeWidth = 0.5,
    );

    for (int dataIndex = 0; dataIndex < data.length; dataIndex++) {
      ChartInput dataElement = data[dataIndex];
      if (dataElement.samples.isEmpty) continue;

      Paint paint = paints[dataIndex];

      if (dataElement.isDiscrete)
        _drawDiscreteFunction(canvas, dataElement.samples, paint);
      else
        _drawContinuousFunction(canvas, dataElement.samples, paint);
    }
  }

  void _drawContinuousFunction(
    Canvas canvas,
    List<Point> samples,
    Paint paint,
  ) {
    canvas.drawPoints(
      PointMode.polygon,
      samples.map(_pointNormalizer).toList(),
      paint,
    );
  }

  void _drawDiscreteFunction(
    Canvas canvas,
    List<Point> samples,
    Paint paint,
  ) {
    Paint pointPaint = Paint()
      ..color = paint.color
      ..strokeWidth = paint.strokeWidth
      ..style = PaintingStyle.fill;

    samples.forEach((sample) {
      canvas.drawLine(
        _pointNormalizer(Point(sample.x, 0.0)),
        _pointNormalizer(Point(sample.x, sample.y)),
        paint,
      );
      canvas.drawCircle(
        _pointNormalizer(sample),
        paint.strokeWidth,
        pointPaint,
      );
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  static Paint _generatePaint(ChartInput data) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..color = data.strokeColor
      ..strokeWidth = data.strokeWidth;
  }
}
