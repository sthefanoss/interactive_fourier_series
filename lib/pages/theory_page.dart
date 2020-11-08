import 'package:catex/catex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../strings/constants.dart';
import '../strings/regular_expressions.dart';
import '../widgets/custom_scaffold.dart';

class TheoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String _language = getLocationCode(context);

    return CustomScaffold(
        appBar: AppBar(
          title: Text(kTheoryTitle[_language]),
          centerTitle: true,
        ),
        body: _buildFourierInformation(context, _language));
  }

  Widget _buildFourierInformation(BuildContext context, String language) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          kHistoryTitle[language],
          style: Theme.of(context).textTheme.headline3,
          textAlign: TextAlign.justify,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            kHistoryText[language],
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Text(
          kEquationsTitle[language],
          style: Theme.of(context).textTheme.headline3,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCaTeX(kA0, context),
                buildCaTeX(kAn, context),
                buildCaTeX(kBn, context),
                buildCaTeX(kw0, context),
                buildCaTeX(kSF, context),
              ],
            ),
          ),
        ),
        Text(
          kUtilizationTitle[language],
          style: Theme.of(context).textTheme.headline3,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            kUtilizationText[language],
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ],
    );
  }

  Widget buildCaTeX(String expression, BuildContext context) {
    return DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.headline6,
      child: CaTeX(expression),
    );
  }
}
