import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/compare-average-chart.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';
import 'package:wfhmovement/widgets/share.dart';

class CompareSteps extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      appBar: AppWidgets.appBar(context, 'You vs others', false),
      child: Container(
        child: ListView(
          padding: EdgeInsets.only(top: 25),
          children: [
            Container(
              padding: EdgeInsets.all(25),
              child: Hero(
                tag: 'compare-chart',
                child: CompareAverageChart(),
                flightShuttleBuilder: AppWidgets.flightShuttleBuilder,
              ),
            ),
            AppWidgets.chartDescription(
              'Your\'s and other\'s difference in movement before and after working from home.',
            ),
            ShareButton(
              widgets: [
                AppWidgets.chartDescription(
                  'My change in movement compared to others before and after working from home.',
                ),
                CompareAverageChart(share: true),
                AppWidgets.chartDescription(
                    'Download WFH movement app to see how your movement has changed.'),
              ],
              text:
                  'Check out how my change in movement compares to others working from home.\nTry yourself by downloading the app https://hci-gu.github.io/#/wfh-movement',
              subject:
                  'This is how my movement has changed after working from home.',
              screen: 'You vs others',
            ),
          ],
        ),
      ),
    );
  }
}
