import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/chart_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/widgets/steps-chart.dart';

class StepsDifference extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var diff = useModel(percentDifferenceSelector);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 25),
      child: Column(children: [
        Text(
          '$diff%',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blueGrey[900],
            fontSize: 48,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        Text(
          'Your average daily steps have decreased by $diff%.',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          'Below you can see how your activity have changed over a typical day before and after working from home.',
        )
      ]),
    );
  }
}
