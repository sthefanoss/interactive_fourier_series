import 'package:flutter/material.dart';
import 'package:ifs/math/fourier_series_input_function.dart';
import 'package:ifs/widgets/function_catalog_grid_tile.dart';

import '../strings/constants.dart';
import '../widgets/custom_scaffold.dart';

class FunctionsCatalogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _language = getLocationCode(context);

    return CustomScaffold(
      appBar: AppBar(
        title: Text(kFunctionsCatalogTitle[_language]),
        centerTitle: true,
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
