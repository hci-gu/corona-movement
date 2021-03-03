import 'package:i18n_extension/i18n_widget.dart';
import 'package:wfhmovement/config.dart';
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
              'Mine and other\'s difference in movement before and after %s from home.'
                  .i18n
                  .fill([
                I18n.of(context).locale.languageCode == 'en'
                    ? AppTexts().working
                    : AppTexts().work,
              ]),
            ),
            PendingComparisons(),
            ShareButton(
              widgets: [
                AppWidgets.chartDescription(
                  'My change in movement compared to others before and after %s from home.'
                      .i18n
                      .fill([
                    I18n.of(context).locale.languageCode == 'en'
                        ? AppTexts().working
                        : AppTexts().work,
                  ]),
                  14,
                ),
                CompareAverageChart(share: true),
              ],
              text:
                  'Check out how my change in movement compares to others working from home.\nTry yourself by downloading the app https://hci-gu.github.io/wfh-movement'
                      .i18n
                      .fill([
                I18n.of(context).locale.languageCode == 'en'
                    ? AppTexts().working
                    : AppTexts().teleworking,
              ]),
              subject: 'This is how my movement has changed after %s from home.'
                  .i18n
                  .fill([
                I18n.of(context).locale.languageCode == 'en'
                    ? AppTexts().working
                    : AppTexts().work,
              ]),
              screen: 'You vs others',
            ),
          ],
        ),
      ),
    );
  }
}
