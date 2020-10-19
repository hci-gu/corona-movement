import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';

import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/day-select.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';
import 'package:wfhmovement/widgets/share.dart';
import 'package:wfhmovement/widgets/steps-chart.dart';
import 'package:wfhmovement/widgets/steps-difference.dart';

class DetailedSteps extends HookWidget {
  GlobalKey _globalKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);

    return MainScaffold(
      appBar: AppWidgets.appBar(context, 'Before & after', true),
      child: ListView(
        padding: EdgeInsets.only(top: 25),
        children: [
          DaySelect(),
          StepsDifference(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Hero(
              tag: 'steps-chart',
              child: StepsChart(),
              flightShuttleBuilder: AppWidgets.flightShuttleBuilder,
            ),
          ),
          AppWidgets.chartDescription(
            user.id == 'all'
                ? 'Above you can see how working from home has affected how people move throughout the day.'
                : 'Above you can see how your activity has changed over a typical day before and after working from home.',
          ),
          ShareButton(
            widgets: [
              StepsDifference(share: true),
              StepsChart(share: true),
            ],
            text:
                'This is how people\'s movement has changed after working from home.\nTry yourself by downloading the app https://hci-gu.github.io/#/wfh-movement',
            subject:
                'This is how how people\'s movement has changed after working from home.',
            screen: 'Before & after',
          ),
        ],
      ),
    );
  }
}
