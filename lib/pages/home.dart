import 'package:flutter/material.dart';
import '../strings/constants.dart';
import '../strings/regular_expressions.dart';
import 'package:flutter_tex/flutter_tex.dart';
import '../widgets/text_loading_widget.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _language = getLocationCode(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(kAppName[_language]),
        centerTitle: true,
        actions: <Widget>[IconButton(icon: Icon(Icons.info_outline),onPressed: (){Navigator.pushNamed(context, '/info');},)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/calc-input');
        },
        child: Icon(Icons.play_arrow),
      ),
      body: SafeArea(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 24, left: 8, right: 8),
              child: TeXView(
                child: TeXViewDocument(kIntroText[_language]),
                renderingEngine: TeXViewRenderingEngine.mathjax(),
                loadingWidgetBuilder: (context) =>
                    TexLoadingWidget(text: kRenderingIntroductionText[_language]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
