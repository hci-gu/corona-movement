import 'package:wfhmovement/api/responses.dart';
import 'package:wfhmovement/i18n.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:wfhmovement/global-analytics.dart';
import 'package:wfhmovement/models/steps/steps.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/style.dart';

class DaysBarChart extends HookWidget {
  final double barWidth = 11.0;
  final ScrollController scrollController = ScrollController(
    initialScrollOffset: 0,
  );
  final List emptyDays = List.generate(
    200,
    (index) => {
      'value': 0.1,
      'date': DateTime.parse(StepsModel.fromDate)
          .add(Duration(days: index))
          .toIso8601String()
          .substring(0, 10)
    },
  );

  @override
  Widget build(BuildContext context) {
    List days = useModel(stepsDayTotalSelector);
    User user = useModel(userAtom);
    List<List<DatePeriod>> periods = useModel(userPeriodsSelector);
    List<DatePeriod> afterPeriods = periods[1];
    useEffect(() {
      if (days.length > 0 && user.id != 'all' && afterPeriods.first != null) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            _scrollOffsetForDays(days, afterPeriods.first?.fromAsString),
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      }
      return;
    }, [days]);

    return Container(
      width: 5000,
      height: 300,
      child: Scrollbar(
        isAlwaysShown: true,
        controller: scrollController,
        child: NotificationListener(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              double offset =
                  _scrollOffsetForDays(days, afterPeriods.first?.fromAsString);
              if (scrollController.offset != offset) {
                globalAnalytics.sendEvent('dayBarChartScroll');
              }
            }
          },
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 20),
            scrollDirection: Axis.horizontal,
            children: [
              _barChart(days.length > 0 ? days : emptyDays, user, afterPeriods,
                  days.length == 0),
            ],
          ),
        ),
      ),
    );
  }

  double _scrollOffsetForDays(days, compareDate) {
    var day = days.firstWhere(
      (day) => compareDate.compareTo(day['date']) == 0,
      orElse: () => null,
    );
    int index = day != null ? days.indexOf(day) : 0;
    return index * barWidth - 50;
  }

  Widget _barChart(days, user, List<DatePeriod> afterPeriods, [bool empty]) {
    double maxValue = days.length > 0
        ? days.fold(
            0.0, (value, day) => value > day['value'] ? value : day['value'])
        : 500.0;

    return Container(
      width: (days.length * barWidth).toDouble(),
      child: BarChart(
        BarChartData(
          maxY: empty ? 10 : maxValue + (maxValue / 10),
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.transparent,
              tooltipPadding: const EdgeInsets.all(0),
              tooltipBottomMargin: 5,
              getTooltipItem: (
                BarChartGroupData group,
                int groupIndex,
                BarChartRodData rod,
                int rodIndex,
              ) {
                var day = days[groupIndex];
                if (_dateIsAtStartOfPeriod(day['date'], afterPeriods)) {
                  return BarTooltipItem(
                    'Started working from home'.i18n,
                    TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                if (_dateIsAtEndOfPeriod(day['date'], afterPeriods)) {
                  return BarTooltipItem(
                    'Stopped working from home'.i18n,
                    TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                var date = DateTime.parse(day['date']);
                var formattedNumber = NumberFormat.decimalPattern('sv-se')
                    .format(day['value'].toInt());
                return BarTooltipItem(
                  '${_labelforDate(date)} - $formattedNumber ' + 'steps'.i18n,
                  TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              showTitles: true,
              textStyle: TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              margin: 10,
              getTitles: (double value) {
                DateTime date;
                try {
                  date = DateTime.parse(days[value.toInt()]['date']);
                  if (date.weekday == 1) {
                    return _labelforDate(date);
                  }
                } catch (_) {
                  return null;
                }

                return null;
              },
              rotateAngle: -10,
            ),
            leftTitles: SideTitles(showTitles: false),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: _barGroupsForDays(days, user, afterPeriods, maxValue),
        ),
      ),
    );
  }

  bool _dateIsAtStartOfPeriod(String dateString, List<DatePeriod> periods) {
    return periods.any(
        (DatePeriod period) => period.fromAsString.compareTo(dateString) == 0);
  }

  bool _dateIsAtEndOfPeriod(String dateString, List<DatePeriod> periods) {
    return periods.any(
        (DatePeriod period) => period.toAsString.compareTo(dateString) == 0);
  }

  bool _dateIsInPeriod(String dateString, List<DatePeriod> periods) {
    DateTime date = DateTime.parse(dateString);
    return periods.any((DatePeriod period) =>
        period.from.isBefore(date) && period.to.isAfter(date));
  }

  String _labelforDate(DateTime date) {
    return '${_month(date.month)} ${date.day}';
  }

  String _month(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May'.i18n;
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct'.i18n;
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
    }
    return '';
  }

  List<BarChartGroupData> _barGroupsForDays(
      List days, User user, List<DatePeriod> afterPeriods, double maxValue) {
    List<BarChartGroupData> barGroups = [];
    days.forEach((day) {
      int index = days.indexOf(day);
      if ((_dateIsAtStartOfPeriod(day['date'], afterPeriods) ||
              _dateIsAtEndOfPeriod(day['date'], afterPeriods)) &&
          user.id != 'all') {
        barGroups.add(
          BarChartGroupData(
            x: index,
            barsSpace: 40,
            barRods: [
              BarChartRodData(
                y: maxValue - (maxValue / 10),
                color: Colors.black,
                width: 1,
              )
            ],
            showingTooltipIndicators: [0],
          ),
        );
      } else {
        Color rodColor = _dateIsInPeriod(day['date'], afterPeriods)
            ? AppColors.main
            : AppColors.secondary;
        if (user.id == 'all') rodColor = AppColors.main;
        barGroups.add(
          BarChartGroupData(x: index, barRods: [
            BarChartRodData(
              y: day['value'],
              color: rodColor,
            )
          ]),
        );
      }
    });
    return barGroups;
  }
}
