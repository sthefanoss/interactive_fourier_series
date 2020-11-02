import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class ChartInput {
  final List<Point<double>> samples;
  final Color strokeColor;
  final double strokeWidth;

  ChartInput({
    @required this.samples,
    this.strokeWidth = 0.05,
    this.strokeColor = Colors.black54,
  });
}

class ChartBoundaries {
  final double maxX;
  final double maxY;
  final double minX;
  final double minY;

  ChartBoundaries({
    this.maxX,
    this.maxY,
    this.minX,
    this.minY,
  });

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
    Size size = const Size.fromHeight(100),
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
  final List<Paint> paints;

  _LineChartPainter(
    this.data,
    this.options,
  )   : xRange = options.maxX - options.minX,
        yRange = options.maxY - options.minY,
        paints = data.map(_generatePaint).toList();

  @override
  void paint(Canvas canvas, Size size) {
    _normalizeCanvas(canvas, size);

    for (int dataIndex = 0; dataIndex < data.length; dataIndex++) {
      ChartInput dataElement = data[dataIndex];
      Paint paint = paints[dataIndex];

      canvas.drawPoints(
        PointMode.polygon,
        dataElement.samples.map((e) => Offset(e.x, e.y)).toList(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void _normalizeCanvas(Canvas canvas, Size size) {
    canvas.scale(size.width / xRange, -size.height / yRange);
    canvas.translate(xRange / 2, -yRange / 2);
  }

  static Paint _generatePaint(ChartInput data) {
    return Paint()
      ..color = data.strokeColor
      ..strokeWidth = data.strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..strokeJoin = StrokeJoin.round;
  }
}
