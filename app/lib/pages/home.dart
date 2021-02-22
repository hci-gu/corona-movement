import 'package:wfhmovement/i18n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wfhmovement/models/steps/steps.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/pages/compare-steps.dart';
import 'package:wfhmovement/pages/today-before.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/button.dart';
import 'package:wfhmovement/widgets/compare-average-chart.dart';
import 'package:wfhmovement/widgets/days-bar-chart.dart';
import 'package:wfhmovement/widgets/join_group_success.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';
import 'package:wfhmovement/widgets/page-widget.dart';
import 'package:wfhmovement/widgets/steps-chart.dart';
import 'package:wfhmovement/widgets/sync-steps.dart';

import 'detailed-steps.dart';

class Home extends HookWidget {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);
    StepsModel steps = useModel(stepsAtom);
    var getStepsChart = useAction(getStepsAction);
    var getStepsComparison = useAction(getStepsComparisonAction);
    var deleteUser = useAction(deleteUserAction);
    useEffect(() {
      getStepsChart();
      getStepsComparison();
      return;
    }, [user.group, user.lastSync]);
    useEffect(() {
      if (!steps.fetching) {
        _refreshController.refreshCompleted();
      }
      return;
    }, [steps.fetching]);

    if (steps.data == null) {}

    return MainScaffold(
      key: Key('Home'),
      appBar: AppWidgets.appBar(context: context, settings: true),
      child: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(),
        onRefresh: () {
          getStepsChart();
          getStepsComparison();
        },
        controller: _refreshController,
        child: Stack(children: [
          ListView(
            padding: EdgeInsets.only(top: 25),
            children: steps.data == null
                ? _empty(context)
                : _body(context, user, deleteUser),
          ),
          JoinGroupMessage(),
        ]),
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
          'Your steps are still processing...\n Pull to refresh.'.i18n,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    ];
  }

  List<Widget> _body(BuildContext context, User user, deleteUser) {
    String description = user.id == 'all'
        ? 'This is the number of steps others have taken each day (on average). Below you can see how working from home has affected how people move throughout the day.'
            .i18n
        : 'This is the number of steps you\'ve taken every day. Below you can pick different views of this data.'
            .i18n;

    return [
      if (user.id == 'all')
        AppWidgets.chartDescription(
            'Since you don’t have any data before working from home, you can\'t compare yourself to others. Below you can see other people’s data.'
                .i18n),
      if (user.id == 'all')
        Center(
          child: StyledButton(
            icon: Icons.add,
            title: 'Add data source'.i18n,
            onPressed: () => deleteUser(),
          ),
        ),
      if (user.id != 'all') SyncSteps(),
      DaysBarChart(),
      AppWidgets.chartDescription(description),
      if (user.id != 'all')
        Text(
          'Explore your steps'.i18n,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          textAlign: TextAlign.center,
        ),
      SizedBox(height: 20),
      _grid(context, user),
    ];
  }

  Widget _grid(BuildContext context, User user) {
    double padding =
        user.id == 'all' ? (MediaQuery.of(context).size.width / 4) : 12;
    return GridView.count(
      padding: EdgeInsets.only(left: padding, right: padding, bottom: 25),
      crossAxisCount: user.id == 'all' ? 1 : 2,
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
          'Before & after'.i18n,
        ),
        if (user.id != 'all')
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
            'You vs others'.i18n,
          ),
        if (user.id != 'all')
          _pageItem(
            PageWidget(
              child: Hero(
                tag: 'today-before',
                child: TodayBeforeText(
                  preview: true,
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
            'Today & before'.i18n,
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
                      color: AppColors.primaryText,
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
