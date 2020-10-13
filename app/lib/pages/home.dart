import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wfhmovement/global-analytics.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
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
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);
    StepsModel steps = useModel(stepsAtom);
    var getStepsChart = useAction(getStepsAction);
    useEffect(() {
      getStepsChart();
      return;
    }, [user.compareDate, user.lastSync]);
    useEffect(() {
      if (!steps.fetching) {
        _refreshController.refreshCompleted();
      }
      return;
    }, [steps.fetching]);

    if (steps.data == null) {}

    return MainScaffold(
      appBar: AppWidgets.appBar(context, null, true),
      child: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(),
        onRefresh: () {
          getStepsChart();
        },
        controller: _refreshController,
        child: ListView(
          padding: EdgeInsets.only(top: 25),
          children: steps.data == null ? _empty(context) : _body(context),
        ),
      ),
    );
  }

  List<Widget> _empty(BuildContext context) {
    return [
      Center(
        child: Text('Steps processing',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      Container(
        margin: EdgeInsets.all(25),
        child: SvgPicture.asset(
          'assets/svg/data_processing.svg',
          height: 150,
        ),
      ),
      Center(
        child: Text(
          'Your steps are still processing...\n Pull to refresh.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    ];
  }

  List<Widget> _body(BuildContext context) {
    return [
      DaysBarChart(),
      AppWidgets.chartDescription(
        'This is the number of steps you\'ve taken every day. Below you can pick different views of this data.',
      ),
      Text(
        'Explore your steps',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.secondary,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 20),
      _grid(context),
    ];
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
                settings: RouteSettings(name: 'Before & after'),
              ));
            },
          ),
          'Before & after',
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
                settings: RouteSettings(name: 'You vs others'),
              ));
            },
          ),
          'You vs others',
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
                Flexible(child: widget),
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
