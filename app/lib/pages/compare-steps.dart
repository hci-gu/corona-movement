import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/compare-average-chart.dart';
import 'package:wfhmovement/widgets/steps-difference.dart';

class CompareSteps extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidgets.appBar(context, 'Compare'),
      body: Container(
        child: ListView(
          padding: EdgeInsets.only(top: 25),
          children: [
            Container(
              padding: EdgeInsets.all(25),
              child: Hero(
                tag: 'compare-chart',
                child: CompareAverageChart(),
                flightShuttleBuilder: AppWidgets.flightShuttleBuilder,
              ),
            ),
            AppWidgets.chartDescription(
              'Your\'s and other\'s progress before and after starting working from home.',
            )
          ],
        ),
      ),
    );
  }
}
