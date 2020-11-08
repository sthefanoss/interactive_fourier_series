import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ifs/math/fourier_series_input_function.dart';
import 'package:ifs/math/linear_space.dart';

import 'line_chart.dart';

class FunctionCatalogGridTile extends StatefulWidget {
  final FourierSeriesInputFunction functionInput;
  const FunctionCatalogGridTile(this.functionInput);

  @override
  _FunctionCatalogGridTileState createState() =>
      _FunctionCatalogGridTileState();
}

class _FunctionCatalogGridTileState extends State<FunctionCatalogGridTile> {
  List<Point<double>> _spots;
  double _maxY;

  @override
  void initState() {
    _updateChartData();

    super.initState();
  }

  void _updateChartData([int numberOfPoints = 256]) {
    final plotData = widget.functionInput.callFromLinearSpace(
      LinearSpace(
        start: widget.functionInput.start,
        end: widget.functionInput.end,
        length: numberOfPoints,
      ),
    );
    _maxY = 1.25 *
        plotData.fold(
            0,
            (previousValue, element) => previousValue.abs() > element.y.abs()
                ? previousValue.abs()
                : element.y.abs());
    setState(() {
      _spots = plotData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: _nextPage,
        child: GridTile(
          header: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.functionInput.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: _spots == null
              ? Container()
              : LineChart(
                  input: [
                    ChartInput(
                      samples: _spots,
                    )
                  ],
                  boundaries: ChartBoundaries(
                    maxY: _maxY,
                    minY: -_maxY,
                    maxX: _spots.last.x,
                    minX: _spots.first.x,
                  ),
                ),
        ),
      ),
    );
  }

  void _nextPage() {
    Navigator.of(context).pushNamed('/func-output', arguments: [
      [widget.functionInput.start, widget.functionInput.end],
      widget.functionInput,
    ]);
  }
}
