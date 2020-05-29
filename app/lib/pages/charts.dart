import 'package:mycoronamovement/models/chart_model.dart';
import 'package:mycoronamovement/models/recoil.dart';
import 'package:mycoronamovement/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class Charts extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var userId = useModel(userIdSelector);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(25),
              child: SvgPicture.asset(
                'assets/svg/remote_work.svg',
                height: 150,
              ),
            ),
            Text(
              'Din data är nu synkad! Besök hemsidan för att se resultatet.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            RaisedButton(
              child: Text('Gå till mycoronamovement.com'),
              onPressed: () async {
                var url = 'https://mycoronamovement.com/user/$userId';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
