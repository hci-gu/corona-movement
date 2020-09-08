import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/global-analytics.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/pages/compare-steps.dart';
import 'package:wfhmovement/pages/today-before.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/compare-average-chart.dart';
import 'package:wfhmovement/widgets/days-bar-chart.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';
import 'package:wfhmovement/widgets/page-widget.dart';
import 'package:wfhmovement/widgets/steps-chart.dart';
import 'package:wfhmovement/widgets/steps-difference.dart';

import 'detailed-steps.dart';

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);
    var getStepsChart = useAction(getStepsAction);
    useEffect(() {
      globalAnalytics.observer.analytics.setCurrentScreen(screenName: 'Home');
      getStepsChart();
      return;
    }, [user.compareDate, user.lastSync]);

    return MainScaffold(
      appBar: AppWidgets.appBar(context, null, true),
      child: Container(
        child: ListView(
          padding: EdgeInsets.only(top: 25),
          children: [
            DaysBarChart(),
            AppWidgets.chartDescription(
              'This is your steps data. Below you can pick different views of this data.',
            ),
            Text(
              'I want to see',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _grid(context),
          ],
        ),
      ),
    );
  }

  Widget _grid(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.only(left: 12, right: 12, bottom: 25),
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _pageItem(
          PageWidget(
            child: Hero(
              tag: 'steps-chart',
              child: StepsChart(),
              flightShuttleBuilder: AppWidgets.flightShuttleBuilder,
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DetailedSteps(),
                settings: RouteSettings(name: 'Detailed Steps'),
              ));
            },
          ),
          'Detailed steps',
        ),
        _pageItem(
          PageWidget(
            child: Hero(
              tag: 'compare-chart',
              child: CompareAverageChart(),
              flightShuttleBuilder: AppWidgets.flightShuttleBuilder,
            ),
            scale: 1.2,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CompareSteps(),
                settings: RouteSettings(name: 'Compare Steps'),
              ));
            },
          ),
          'Me vs others',
        ),
        _pageItem(
          PageWidget(
            child: Hero(
              tag: 'today-before',
              child: TodayBeforeText(
                padding: EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 75,
                ),
              ),
              flightShuttleBuilder: AppWidgets.flightShuttleBuilder,
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TodayBefore(),
                settings: RouteSettings(name: 'Today & Before'),
              ));
            },
            scale: 1.25,
          ),
          'Today & Before',
        ),
      ],
    );
  }

  Widget _pageItem(Widget widget, String title) {
    return Card(
      elevation: 1.5,
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(10),
          child: InkWell(
            child: Column(
              children: [
                Flexible(
                  child: widget,
                ),
                FittedBox(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
