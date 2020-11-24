import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/api/responses.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/style.dart';

class CompareAverageChart extends HookWidget {
  final bool share;

  CompareAverageChart({
    key,
    this.share: false,
  }) : super(key: key);

  static const double barWidth = 22;

  @override
  Widget build(BuildContext context) {
    HealthComparison comparison = useModel(stepsComparisonSelector);
    double maxY = 100;
    if (comparison != null) {
      maxY = maxValue(comparison);
    }

    return RotatedBox(
      quarterTurns: 1,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: AspectRatio(
          aspectRatio: share ? 0.6 : 0.44,
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
              maxY: maxY,
              minY: -maxY,
              groupsSpace: 12,
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.transparent,
                  tooltipPadding: EdgeInsets.all(0),
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
                    fontWeight: FontWeight.w800,
                  ),
                  margin: 40,
                  rotateAngle: -90,
                  getTitles: (double value) {
                    String name = comparison.comparisons[value.toInt()].name;
                    if (name == 'user') return 'You';
                    return '${name[0].toUpperCase()}${name.substring(1, name.length)}';
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
    return comparison.comparisons.map((HealthSummary summary) {
      int index = comparison.comparisons.indexOf(summary);
      double diff = _diffForSummary(summary);
      return BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            color: index == 0 ? AppColors.main : AppColors.secondary,
            y: double.parse(diff.toStringAsFixed(1)),
            width: barWidth,
            borderRadius: _radiusForValue(diff),
            rodStackItem: [],
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  double maxValue(HealthComparison comparison) {
    return (max(
              _diffForSummary(comparison.user).abs(),
              _diffForSummary(comparison.others).abs(),
            ) *
            1.4)
        .roundToDouble();
  }

  double _diffForSummary(HealthSummary summary) {
    return ((summary.after - summary.before) / summary.before) * 100;
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
