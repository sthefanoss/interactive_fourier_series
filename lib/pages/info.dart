import 'package:flutter/material.dart';
import '../strings/constants.dart';



class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _language = getLocationCode(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Info'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Column(
              children: <Widget>[
                Container(
                  child: CircleAvatar(
                    radius: 80, backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/tt.png'),

                    // backgroundColor: Colors.transparent,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(120),
                      border: Border.all(
                          width: 5,
                          color: const Color(0xFFECEFF1),
                          style: BorderStyle.solid)),
                ),
                Text(
                  kDevelopedBy,
                  style: Theme.of(context).textTheme.title,
                ),
                Text(kStudentOf[_language],
                    style: Theme.of(context).textTheme.subtitle),
                Text(
                  kGMail,
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  kThanksTo[_language],
                  style: Theme.of(context).textTheme.body2,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  'Gilmar de Oliveira Gomes',
                  style: Theme.of(context).textTheme.body1,
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  'Laris Designer',
                  style: Theme.of(context).textTheme.body1,
                ),
                Text(
                  'instagram.com/laris_designer',
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  kThirdPartyLibs[_language] + ' (Flutter)',
                  style: Theme.of(context).textTheme.body2,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  'function_tree',
                  style: Theme.of(context).textTheme.body1,
                ),
                Text(
                  'flutter_tex',
                  style: Theme.of(context).textTheme.body1,
                ),
                Text(
                  'fl_chart',
                  style: Theme.of(context).textTheme.body1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
