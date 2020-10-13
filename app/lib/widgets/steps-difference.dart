import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/style.dart';

class StepsDifference extends HookWidget {
  final bool share;

  StepsDifference({
    key,
    this.share: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var diff = useModel(stepsDiffBeforeAndAfterSelector);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: share ? 20 : 60, vertical: share ? 0 : 25),
      child: Column(children: [
        Text(
          '${diff != null ? diff : '-'}%',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: share ? 32 : 48,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        Text(
          _textForDiff(
            diff,
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: share ? 14 : 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      ]),
    );
  }

  String _textForDiff(diff) {
    String who = 'You\'re';
    if (share) {
      who = 'I\'m';
    }

    if (diff == null) {
      return '$who movement hasn\'t changed';
    }
    return '$who moving $diff% ${double.parse(diff) > 0 ? 'more' : 'less'}${share ? ' since working from home.' : '.'}';
  }
}
