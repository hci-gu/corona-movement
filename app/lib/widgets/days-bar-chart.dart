import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/style.dart';

class DaysBarChart extends HookWidget {
  double barWidth = 11.0;
  ScrollController scrollController = ScrollController();

  List emptyDays = List.generate(
      200,
      (index) => {
            'value': 0.1,
            'date': DateTime.parse('2020-01-01')
                .add(Duration(days: index))
                .toIso8601String()
                .substring(0, 10)
          });

  @override
  Widget build(BuildContext context) {
    List days = useModel(stepsDayTotalSelector);
    List<String> dates = useModel(userDatesSelector);
    useEffect(() {
      if (days.length > 0) {
        String compareDate = dates[1];
        var day =
            days.firstWhere((day) => compareDate.compareTo(day['date']) == 0);
        int index = days.indexOf(day);

        scrollController.animateTo(index * barWidth - 50,
            duration: Duration(milliseconds: 500), curve: Curves.easeOut);
      }
      return;
    }, [days]);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 25),
      child: Container(
        width: 5000,
        height: 300,
        child: Scrollbar(
          isAlwaysShown: true,
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.only(top: 10, bottom: 45, right: 10, left: 10),
            scrollDirection: Axis.horizontal,
            children: [
              _barChart(days.length > 0 ? days : emptyDays, dates[1],
                  days.length == 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barChart(days, String compareDate, [bool empty]) {
    double maxValue = days.length > 0
        ? days.fold(
            0, (value, day) => value > day['value'] ? value : day['value'])
        : 500;

    return Container(
      width: (days.length * barWidth).toDouble(),
      child: BarChart(
        BarChartData(
          maxY: empty ? 10 : maxValue + (maxValue / 10),
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            enabled: false,
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
                return BarTooltipItem(
                  'Started working from home',
                  TextStyle(
                    color: AppColors.secondaryText,
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
                DateTime date = DateTime.parse(days[value.toInt()]['date']);
                if (date.weekday == 1) {
                  return _labelforDate(date);
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
          barGroups: _barGroupsForDays(days, compareDate, maxValue),
        ),
      ),
    );
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
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
    }
  }

  List<BarChartGroupData> _barGroupsForDays(
      List days, String compareDate, double maxValue) {
    List<BarChartGroupData> barGroups = [];
    days.forEach((day) {
      int index = days.indexOf(day);
      if (compareDate.compareTo(day['date']) == 0) {
        barGroups.add(
          BarChartGroupData(
            x: index,
            barsSpace: 40,
            barRods: [
              BarChartRodData(
                y: maxValue - (maxValue / 10),
                color: AppColors.secondaryText,
                width: 5,
              )
            ],
            showingTooltipIndicators: [0],
          ),
        );
      } else {
        barGroups.add(
          BarChartGroupData(x: index, barRods: [
            BarChartRodData(
              y: day['value'],
              color: compareDate.compareTo(day['date']) >= 1
                  ? AppColors.secondary
                  : AppColors.main,
            )
          ]),
        );
      }
    });
    return barGroups;
  }
}
