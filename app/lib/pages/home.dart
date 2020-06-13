import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/pages/compare-steps.dart';
import 'package:wfhmovement/pages/settings.dart';
import 'package:wfhmovement/pages/today-before.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/compare-average-chart.dart';
import 'package:wfhmovement/widgets/days-bar-chart.dart';
import 'package:wfhmovement/widgets/page-widget.dart';
import 'package:wfhmovement/widgets/steps-chart.dart';
import 'package:wfhmovement/widgets/steps-difference.dart';

import 'detailed-steps.dart';

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var getStepsChart = useAction(getStepsAction);
    useEffect(() {
      getStepsChart();
      return;
    }, []);

    return Scaffold(
      appBar: AppWidgets.appBar(context),
      body: Container(
        child: ListView(
          padding: EdgeInsets.only(top: 25),
          children: [
            DaysBarChart(),
            AppWidgets.chartDescription(
              'This is your steps data. Below you can pick different views of this data.',
            ),
            _grid(),
          ],
        ),
      ),
    );
  }

  Widget _grid() {
    return GridView.count(
      padding: EdgeInsets.symmetric(horizontal: 12),
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _pageItem(
          PageWidget(
            child: Hero(
              tag: 'steps-chart',
              child: StepsChart(),
              flightShuttleBuilder: (
                BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,
              ) {
                return SingleChildScrollView(
                  child: fromHeroContext.widget,
                );
              },
            ),
            destination: DetailedSteps(),
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
            destination: CompareSteps(),
          ),
          'Compare',
        ),
        _pageItem(
          PageWidget(
            child: Hero(
              tag: 'today-before',
              child: StepsDifference(),
              flightShuttleBuilder: AppWidgets.flightShuttleBuilder,
            ),
            destination: TodayBefore(),
          ),
          'Today & Before',
        ),
      ],
    );
  }

  Widget _pageItem(Widget widget, String title) {
    return Column(
      children: [
        widget,
        FittedBox(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
