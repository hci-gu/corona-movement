import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/chart_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/widgets/days-bar-chart.dart';
import 'package:wfhmovement/widgets/steps-chart.dart';
import 'package:wfhmovement/widgets/steps-difference.dart';

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var getStepsChart = useAction(getStepsChartAction);
    useEffect(() {
      getStepsChart();
      return;
    }, []);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'WFH Movement',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        child: ListView(
          padding: EdgeInsets.only(top: 25),
          children: [
            StepsDifference(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: StepsChart(),
            ),
            DaysBarChart(),
          ],
        ),
      ),
    );
  }
}
