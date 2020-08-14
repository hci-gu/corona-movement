import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/steps-difference.dart';

class TodayBefore extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidgets.appBar(context, 'Today & Before', false),
      body: Hero(
        tag: 'today-before',
        child: TodayBeforeText(),
        flightShuttleBuilder: AppWidgets.flightShuttleBuilder,
      ),
    );
  }
}

class TodayBeforeText extends HookWidget {
  final EdgeInsets padding;

  TodayBeforeText({
    this.padding = const EdgeInsets.all(25),
  });

  @override
  Widget build(BuildContext context) {
    int stepsToday = useModel(stepsTodaySelector);
    int typicalSteps = useModel(typicalStepsSelector);
    double diff = (100 * (stepsToday - typicalSteps) / stepsToday);

    return Container(
      child: ListView(
        padding: padding,
        children: [
          RichText(
            text: TextSpan(
              text: 'Today you have taken ',
              style: TextStyle(
                  fontSize: 22, color: Colors.black, fontFamily: 'Poppins'),
              children: [
                TextSpan(
                  text: stepsToday.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text:
                      ' steps so far. On a typical ${DateFormat('EEEE').format(DateTime.now())}, before working from home, you had normally taken ',
                ),
                TextSpan(
                  text: typicalSteps.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: ' steps at this time of day.'),
              ],
            ),
          ),
          SizedBox(height: 25),
          if (diff.isFinite && !diff.isNaN)
            Text(
              'This is a ${diff > 0 ? 'increase' : 'decrease'} of ${diff.toStringAsFixed(1)}%.',
            ),
        ],
      ),
    );
  }
}
