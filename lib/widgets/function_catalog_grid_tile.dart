import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ifs/math/fourier_series_input_function.dart';
import 'package:ifs/math/linear_space.dart';

class FunctionCatalogGridTile extends StatefulWidget {
  final FourierSeriesInputFunction functionInput;
  const FunctionCatalogGridTile(this.functionInput);

  @override
  _FunctionCatalogGridTileState createState() =>
      _FunctionCatalogGridTileState();
}

class _FunctionCatalogGridTileState extends State<FunctionCatalogGridTile> {
  List<FlSpot> _spots;
  double _maxY;

  @override
  void initState() {
    _updateChartData();

    super.initState();
  }

  void _updateChartData([int numberOfPoints = 1024]) {
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
      _spots = plotData.map((e) => FlSpot(e.x, e.y)).toList();
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
                  LineChartData(
                    gridData: FlGridData(show: false),
                    extraLinesData: ExtraLinesData(horizontalLines: [
                      HorizontalLine(
                          y: 0, strokeWidth: 0.5, color: Colors.black26)
                    ]),
                    maxY: _maxY,
                    minY: -_maxY,
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false
                        //bottomTitles:
                        //   SideTitles(showTitles: true, getTitles: _xGenerator),
                        ),
                    lineTouchData: LineTouchData(enabled: false),
                    lineBarsData: [
                      LineChartBarData(
                          spots: _spots,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          colors: [Colors.blueGrey.withOpacity(0.5)]),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _nextPage() {
    Navigator.of(context).pushNamed('/calc-result', arguments: [
      [widget.functionInput.start, widget.functionInput.end],
      widget.functionInput,
    ]);
  }
}
