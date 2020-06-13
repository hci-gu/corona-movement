import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/style.dart';

class StepsDifference extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var diff = useModel(stepsDiffBeforeAndAfterSelector);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 25),
      child: Column(children: [
        Text(
          '${diff != null ? diff : '-'}%',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 48,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        Text(
          _textForDiff(diff),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w300,
          ),
        ),
      ]),
    );
  }

  String _textForDiff(diff) {
    if (diff == null) {
      return 'Your average daily steps have\n changed by -%.';
    }
    return 'Your average daily steps have\n ${double.parse(diff) > 0 ? 'increased' : 'decreased'} by $diff%.';
  }
}
