import 'package:wfhmovement/i18n.dart';

import 'package:flutter/material.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/compare-average-chart.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';
import 'package:wfhmovement/widgets/pending-comparisons.dart';
import 'package:wfhmovement/widgets/share.dart';

class CompareSteps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      appBar: AppWidgets.appBar(context: context, title: 'You & others'.i18n),
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
              'Mine and other\'s difference in movement before and after working from home.'
                  .i18n,
            ),
            PendingComparisons(),
            ShareButton(
              widgets: [
                AppWidgets.chartDescription(
                  'My change in movement compared to others before and after working from home.'
                      .i18n,
                  14,
                ),
                CompareAverageChart(share: true),
              ],
              text:
                  'Check out how my change in movement compares to others working from home.\nTry yourself by downloading the app https://hci-gu.github.io/wfh-movement'
                      .i18n,
              subject:
                  'This is how my movement has changed after working from home.'
                      .i18n,
              screen: 'You vs others',
            ),
          ],
        ),
      ),
    );
  }
}
