import 'package:flutter/material.dart';

class ContentPage extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget subContent;
  final bool withPadding;

  ContentPage({
    this.title,
    this.content,
    this.subContent,
    this.withPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.headline5,
        ),
        if (withPadding)
          Padding(padding: const EdgeInsets.all(8.0), child: content),
        if (!withPadding) content,
        if (subContent != null) subContent,
      ],
    );
  }
}
