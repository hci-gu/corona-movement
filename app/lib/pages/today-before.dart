import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/steps-chart.dart';
import 'package:wfhmovement/widgets/steps-difference.dart';

class TodayBefore extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidgets.appBar(context, 'Today & Before', false),
      body: Container(
        child: ListView(
          padding: EdgeInsets.only(top: 25),
          children: [
            StepsDifference(),
            AppWidgets.chartDescription(
              'Above you can see how your activity have changed over a typical day before and after working from home.',
            ),
          ],
        ),
      ),
    );
  }
}
