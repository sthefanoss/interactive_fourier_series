import 'package:catex/catex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ifs/widgets/content_page.dart';

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
        ContentPage(
          title: kHistoryTitle[language],
          content: Text(
            kHistoryText[language],
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        ContentPage(
          title: kEquationsTitle[language],
          content: SingleChildScrollView(
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
        ContentPage(
          title: kUtilizationTitle[language],
          content: Text(
            kUtilizationText[language],
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      ],
    );
  }

  Widget buildCaTeX(String expression, BuildContext context) {
    return DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.subtitle2,
      child: CaTeX(expression),
    );
  }
}
