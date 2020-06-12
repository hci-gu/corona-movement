import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/api.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/style.dart';

class CompareAverageChart extends HookWidget {
  static const double barWidth = 22;

  @override
  Widget build(BuildContext context) {
    HealthComparison comparison = useModel(stepsComparisonSelector);
    var getStepsComparison = useAction(getStepsComparisonAction);

    useEffect(() {
      getStepsComparison();
      return;
    }, []);

    return RotatedBox(
      quarterTurns: 1,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: AspectRatio(
          aspectRatio: 0.35,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: true,
                checkToShowHorizontalLine: (value) => value % 5 == 0,
                getDrawingHorizontalLine: (value) {
                  if (value == 0) {
                    return FlLine(color: AppColors.secondary, strokeWidth: 1);
                  }
                  return FlLine(color: Colors.transparent, strokeWidth: 0);
                },
              ),
              alignment: BarChartAlignment.spaceEvenly,
              maxY: 100,
              minY: -100,
              groupsSpace: 12,
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
                      '${rod.y.toString()}%',
                      TextStyle(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              axisTitleData: FlAxisTitleData(show: false),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: SideTitles(showTitles: false),
                bottomTitles: SideTitles(
                  showTitles: true,
                  textStyle: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  margin: 50,
                  rotateAngle: -90,
                  getTitles: (double value) {
                    switch (value.toInt()) {
                      case 0:
                        return 'You';
                      case 1:
                        return 'Others';
                    }
                    return null;
                  },
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: _barGroupData(comparison),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _barGroupData(HealthComparison comparison) {
    if (comparison == null) return [];
    double userDiff =
        100 - (comparison.user.before / comparison.user.after) * 100;
    double othersDiff = comparison.others.before != null
        ? 100 - (comparison.others.before / comparison.others.after) * 100
        : 0.0;

    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            color: AppColors.main,
            y: double.parse(userDiff.toStringAsFixed(1)),
            width: barWidth,
            borderRadius: _radiusForValue(userDiff),
            rodStackItem: [],
          ),
        ],
        showingTooltipIndicators: [0],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            color: AppColors.primaryText,
            y: double.parse(othersDiff.toStringAsFixed(1)),
            width: barWidth,
            borderRadius: _radiusForValue(othersDiff),
            rodStackItem: [],
          ),
        ],
        showingTooltipIndicators: [0],
      ),
    ];
  }

  BorderRadius _radiusForValue(double value) {
    if (value > 0) {
      return BorderRadius.only(
        topLeft: Radius.circular(6),
        topRight: Radius.circular(6),
      );
    }
    return BorderRadius.only(
      bottomLeft: Radius.circular(6),
      bottomRight: Radius.circular(6),
    );
  }
}
