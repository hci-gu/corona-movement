import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
            'Above you can see how your activity have changed over a typical day before and after working from home.',
          ),
          ShareButton(
            widgets: [
              StepsDifference(share: true),
              StepsChart(share: true),
              AppWidgets.chartDescription(
                'Download WFH movement app to try it out yourself.',
              ),
            ],
            text:
                'This is how my movement have changed after working from home.\nTry yourself by downloading the app https://hci-gu.github.io/#/wfh-movement',
            subject:
                'This is how my movement have changed after working from home.',
            screen: 'Before & after',
          ),
        ],
      ),
    );
  }
}
