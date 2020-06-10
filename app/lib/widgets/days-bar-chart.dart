import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/chart_model.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/inner-shadow.dart';

class DaysBarChart extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var days = useModel(dayTotalSelector);
    List<String> dates = useModel(userDatesSelector);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 25),
      child: Container(
        width: 5000,
        height: 300,
        child: Scrollbar(
          isAlwaysShown: true,
          child: ListView(
            padding: EdgeInsets.only(top: 10, bottom: 20),
            reverse: true,
            scrollDirection: Axis.horizontal,
            children: [
              _barChart(days, dates[1]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barChart(days, String compareDate) {
    double maxValue = days.fold(
        0, (value, day) => value > day['value'] ? value : day['value']);

    return Container(
      width: (days.length * 11).toDouble(),
      child: BarChart(
        BarChartData(
          maxY: maxValue + (maxValue / 10),
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
                  'Started WFH',
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
                  return days[value.toInt()]['date'].substring(5, 10);
                }
                return null;
              },
              rotateAngle: -15,
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
                y: maxValue - 2000,
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
