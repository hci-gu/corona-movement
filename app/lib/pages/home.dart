import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/widgets/steps-chart.dart';
import 'package:wfhmovement/widgets/steps-difference.dart';

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
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
        margin: EdgeInsets.only(top: 25),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            StepsDifference(),
            StepsChart(),
          ],
        ),
      ),
    );
  }
}
