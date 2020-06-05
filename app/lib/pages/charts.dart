import 'package:fl_chart/fl_chart.dart';
import 'package:wfhmovement/api.dart';
import 'package:wfhmovement/models/chart_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class Charts extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var userId = useModel(userIdSelector);
    // var sliderValue = useModel(chartOffsetSelector);
    // var data = useModel(chartDataSelector);
    // var getStepsChart = useAction(getStepsChartAction);
    // useEffect(() {
    //   print(sliderValue.value);
    //   getStepsChart();
    // }, [sliderValue.value]);
    // useMemoized(() {
    //   getStepsChart();
    // });

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(25),
              child: SvgPicture.asset(
                'assets/svg/remote_work.svg',
                height: 150,
              ),
            ),
            Text(
              'Din data är nu synkad! Besök hemsidan för att se resultatet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 50),
            RaisedButton(
              child: Text('Gå till mycoronamovement.com'),
              onPressed: () async {
                var url = 'https://mycoronamovement.com/user/$userId';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            // Slider(
            //   value: sliderValue.value.toDouble(),
            //   min: -50,
            //   max: 50,
            //   onChanged: (value) {
            //     sliderValue.value = value.toInt();
            //   },
            // ),
            // if (data.length > 0) _chart(data),
          ],
        ),
      ),
    );
  }

  Widget _chart(List data) {
    List<FlSpot> spots = [];

    data.forEach((element) {
      spots.add(FlSpot(element.key.roundToDouble(), element.value));
    });

    return Container(
      width: 600,
      height: 300,
      child: Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                enabled: false,
              ),
              gridData: FlGridData(
                show: false,
              ),
              titlesData: FlTitlesData(
                bottomTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 12,
                  textStyle: const TextStyle(
                    color: Color(0xff72719b),
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                  margin: 5,
                  getTitles: (value) {
                    return value.toString();
                  },
                ),
                leftTitles: SideTitles(
                  showTitles: false,
                  textStyle: const TextStyle(
                    color: Color(0xff75729e),
                    fontWeight: FontWeight.normal,
                    fontSize: 8,
                  ),
                  getTitles: (value) {
                    return value.toString();
                  },
                  margin: 10,
                  reservedSize: 40,
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  colors: const [
                    Color(0x99aa4cfc),
                  ],
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: false,
                  ),
                  belowBarData: BarAreaData(show: true, colors: [
                    const Color(0x33aa4cfc),
                  ]),
                ),
                // LineChartBarData(
                //   spots: [],
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
