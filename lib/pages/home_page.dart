import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../strings/constants.dart';
import '../widgets/custom_scaffold.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String _language = getLocationCode(context);

    return CustomScaffold(
      appBar: AppBar(
        title: Text(kAppName[_language]),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              width: 175,
              height: 175,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 5, color: Colors.black54),
                image: DecorationImage(
                  image: AssetImage(
                    'assets/fourier.jpg',
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(8),
            title: Text(kTheoryTitle[_language]),
            subtitle: Text(kTheorySubtitle[_language]),
            onTap: () => Navigator.pushNamed(context, '/theory'),
            leading: Icon(
              Icons.text_snippet_outlined,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(8),
            title: Text(kFunctionsCatalogTitle[_language]),
            subtitle: Text(kFunctionsCatalogSubtitle[_language]),
            onTap: () => Navigator.pushNamed(context, '/func-cat'),
            leading: Icon(
              Icons.stacked_line_chart,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(8),
            title: Text(kFunctionInputTitle[_language]),
            subtitle: Text(kFunctionInputSubtitle[_language]),
            onTap: () => Navigator.pushNamed(context, '/func-input'),
            leading: Icon(
              Icons.input,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(8),
            title: Text(kAbout[_language]),
            onTap: () => Navigator.pushNamed(context, '/about'),
            leading: Icon(
              Icons.info_outline,
            ),
          ),
        ],
      ),
    );
  }
}
