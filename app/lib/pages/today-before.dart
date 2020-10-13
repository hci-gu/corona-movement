import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';
import 'package:wfhmovement/widgets/share.dart';

class TodayBefore extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      appBar: AppWidgets.appBar(context, 'Today & Before', false),
      child: Hero(
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
          _description(stepsToday, typicalSteps, false),
          SizedBox(height: 25),
          if (diff.isFinite && !diff.isNaN)
            Text(
              'This is a ${diff > 0 ? 'increase' : 'decrease'} of ${diff.toStringAsFixed(1)}%.',
            ),
          SizedBox(
            height: 50,
          ),
          ShareButton(
            widgets: [
              _description(stepsToday, typicalSteps, true),
              AppWidgets.chartDescription(
                'Download WFH movement app to see how your movement has changed.',
              ),
            ],
            text:
                'Check out how my change in movement compares to others working from home.\nTry yourself by downloading the app https://hci-gu.github.io/#/wfh-movement',
            subject:
                'This is how my movement have changed after working from home.',
            screen: 'Today & before',
          ),
        ],
      ),
    );
  }

  _description(stepsToday, typicalSteps, share) {
    return RichText(
      text: TextSpan(
        text: 'Today ${share ? 'I' : 'you'} have taken ',
        style:
            TextStyle(fontSize: 22, color: Colors.black, fontFamily: 'Poppins'),
        children: [
          TextSpan(
            text: stepsToday.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text:
                ' steps so far. On a typical ${DateFormat('EEEE').format(DateTime.now())}, before working from home, ${share ? 'I' : 'you'} had normally taken ',
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
    );
  }
}
