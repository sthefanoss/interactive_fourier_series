import 'package:flutter/material.dart';
import 'package:ifs/math/fourier_series_input_function.dart';
import 'package:ifs/widgets/function_catalog_grid_tile.dart';

class FunctionCatalogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _language = getLocationCode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(kFunctionsCatalog[_language]),
        centerTitle: true,
      ),
      floatingActionButton: Opacity(
        opacity: 0.5,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/calc-input');
          },
          child: Icon(Icons.add_chart),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        padding: const EdgeInsets.all(8),
        itemCount: FourierSeriesInputFunction.examples.length,
        itemBuilder: (context, index) => FunctionCatalogGridTile(
          FourierSeriesInputFunction.examples[index],
        ),
      ),
    );
  }
}
