import 'package:activity_fetcher/models/recoil.dart';
import 'package:activity_fetcher/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var auth = useAction(getHealthAuthorization);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(25),
              child: SvgPicture.asset(
                'assets/svg/activity.svg',
                height: 150,
              ),
            ),
            Text(
              'Ta reda på hur dina rörelsemönster påverkats av Corona',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Intresserad?',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            OutlineButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_run,
                    color: Colors.pink,
                    size: 24.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  SizedBox(width: 10),
                  Text('Sätt igång')
                ],
              ),
              onPressed: () {
                auth();
              },
            ),
          ],
        ),
      ),
    );
  }
}
