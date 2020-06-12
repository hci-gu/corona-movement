import 'package:fl_chart/fl_chart.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/style.dart';

class StepsChart extends HookWidget {
  Color beforeColor = AppColors.secondary;
  Color afterColor = AppColors.main;

  @override
  Widget build(BuildContext context) {
    StepsModel chart = useModel(stepsAtom);
    List data = useModel(stepsBeforeAndAfterSelector);
    List totalSteps = useModel(totalStepsBeforeAndAfterSelector);

    if (chart.fetching) {
      return _chartBody(
          context,
          Center(
            child: CircularProgressIndicator(),
          ));
    }

    return Center(
      child: Container(
        child: Column(
          children: [
            _totalSteps(totalSteps[0], totalSteps[1]),
            _chart(context, data),
          ],
        ),
      ),
    );
  }

  Widget _totalSteps(int stepsBefore, int stepsAfter) {
    TextStyle textStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w300,
      height: 0.9,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Before', style: textStyle),
              Text(
                stepsBefore.toString(),
                style: TextStyle(
                  fontSize: 36,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: beforeColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('After', style: textStyle),
              Text(
                stepsAfter.toString(),
                style: TextStyle(
                  fontSize: 36,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: afterColor,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _chartBody(BuildContext context, Widget child) {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      width: MediaQuery.of(context).size.width,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        gradient: AppColors.backgroundGradient,
      ),
      child: child,
    );
  }

  Widget _chart(BuildContext context, List data) {
    double maxBefore =
        data[0].fold(0, (_max, o) => o['value'] > _max ? o['value'] : _max);
    double maxAfter =
        data[1].fold(0, (_max, o) => o['value'] > _max ? o['value'] : _max);
    double max = maxBefore > maxAfter ? maxBefore : maxAfter;

    return _chartBody(
      context,
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: LineChart(
            LineChartData(
              maxY: max + max / 5,
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: AppColors.primaryText,
                  fitInsideVertically: true,
                  fitInsideHorizontally: true,
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    double beforeVal =
                        touchedBarSpots.firstWhere((o) => o.barIndex == 0).y;
                    double afterVal =
                        touchedBarSpots.firstWhere((o) => o.barIndex == 1).y;
                    double diff = 100 - (beforeVal / afterVal) * 100;
                    return [
                      LineTooltipItem(
                        '${touchedBarSpots[0].x.toInt()}:00\n ${diff.toStringAsFixed(2)} %',
                        TextStyle(
                            color: AppColors.main, fontWeight: FontWeight.bold),
                      ),
                      null,
                    ];
                  },
                ),
              ),
              gridData: FlGridData(
                show: false,
              ),
              titlesData: FlTitlesData(
                bottomTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  textStyle: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  margin: 10,
                  getTitles: (value) {
                    if (value == 2) return '00:00';
                    if (value == 12) return '12:00';
                    if (value == 21) return '23:00';
                    return null;
                  },
                ),
                leftTitles: SideTitles(
                  showTitles: false,
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              lineBarsData: _lineBarsData(data),
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _spotsForData(data) {
    List<FlSpot> spots = [];
    data.forEach((element) {
      spots.add(FlSpot(element['key'].roundToDouble(), element['value']));
    });

    return spots;
  }

  List<LineChartBarData> _lineBarsData(List data) {
    List<List<FlSpot>> spotLists = data.map(_spotsForData).toList();
    return spotLists.map((spots) {
      int index = spotLists.indexOf(spots);
      return LineChartBarData(
        preventCurveOverShooting: true,
        spots: spots,
        isCurved: true,
        colors: [
          index == 0 ? beforeColor : afterColor,
        ],
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
      );
    }).toList();
  }
}
