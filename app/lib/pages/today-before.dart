import 'package:i18n_extension/i18n_widget.dart';
import 'package:wfhmovement/i18n/today-before.i18n.dart';

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
      appBar: AppWidgets.appBar(context, 'Today & before'.i18n, false),
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
  final bool preview;

  TodayBeforeText({
    this.padding = const EdgeInsets.all(25),
    this.preview = false,
  });

  @override
  Widget build(BuildContext context) {
    int stepsToday = useModel(stepsTodaySelector);
    int typicalSteps = useModel(typicalStepsSelector);
    double diff = (100 * (stepsToday - typicalSteps) / stepsToday);
    String diffText = diff > 0 ? 'increase'.i18n : 'decrease'.i18n;

    return Container(
      child: ListView(
        padding: padding,
        children: [
          _description(context, stepsToday, typicalSteps, false),
          SizedBox(height: 25),
          if (diff.isFinite && !diff.isNaN)
            Text(
              'This is a %s of %s.'
                  .i18n
                  .fill([diffText, '${diff.toStringAsFixed(1)}%']),
            ),
          SizedBox(
            height: 50,
          ),
          if (!preview)
            ShareButton(
              widgets: [
                _description(context, stepsToday, typicalSteps, true),
              ],
              text:
                  'Check out how my change in movement compares to others working from home.\nTry yourself by downloading the app https://hci-gu.github.io/wfh-movement'
                      .i18n,
              subject:
                  'This is how my movement have changed after working from home.'
                      .i18n,
              screen: 'Today & before',
            ),
        ],
      ),
    );
  }

  _description(context, stepsToday, typicalSteps, share) {
    String subject = share ? 'I'.i18n : 'you'.i18n;
    String day = DateFormat('EEEE', I18n.of(context).locale.languageCode)
        .format(DateTime.now());

    return RichText(
      text: TextSpan(
        text: 'Today %s have taken '.i18n.fill([subject]),
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
                ' steps so far. On a typical %s, before working from home, %s had normally taken '
                    .i18n
                    .fill([day, subject]),
          ),
          TextSpan(
            text: typicalSteps.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: ' steps at this time of day.'.i18n),
        ],
      ),
    );
  }
}
