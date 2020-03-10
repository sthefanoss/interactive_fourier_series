import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import '../constants/regular_expressions.dart';
import '../widgets/text_loading_widget.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ajuda'),
        ),
        body: TeXView(
          teXHTML: kIntroText,
          renderingEngine: RenderingEngine.MathJax,
          loadingWidget:
              TexLoadingWidget(text:'Renderizando Ajuda\nAguarde, por favor.'),
        ),
      ),
    );
  }
}
