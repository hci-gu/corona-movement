import 'package:wfhmovement/i18n.dart';

import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/widgets/button.dart';

class StepsEstimate extends HookWidget {
  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);
    var updateEstimate = useAction(updateEstimateAction);

    return Container(
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            margin: EdgeInsets.all(25),
            child: SvgPicture.asset(
              'assets/svg/activity.svg',
              height: 100,
            ),
          ),
          if (user.gaveEstimate) ...gaveEstimate(context, user),
          if (!user.gaveEstimate) ...giveEstimate(context, user, updateEstimate)
        ]),
      ),
    );
  }

  List<Widget> giveEstimate(BuildContext context, User user, updateEstimate) {
    return [
      Text(
        'How much do you think your movement has changed?'.i18n,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 25),
      Text(
        'Use the slider below to give an estimate (in percentage) of how much you think your average daily steps have changed.'
            .i18n,
      ),
      SizedBox(height: 15),
      Text(
        textForEstimate(user.stepsEstimate),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Slider(
        value: user.stepsEstimate,
        min: -1,
        max: 2,
        divisions: 60,
        onChanged: (double value) {
          user.setStepsEstimate(value);
        },
      ),
      SizedBox(height: 20),
      StyledButton(
        icon: Icons.check,
        title: 'Set estimate'.i18n,
        onPressed: () {
          user.setGaveEstimate(true);
          updateEstimate();
        },
      ),
    ];
  }

  List<Widget> gaveEstimate(BuildContext context, User user) {
    return [
      SizedBox(height: 20),
      Text(
        textForEstimate(user.stepsEstimate),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 20),
      StyledButton(
        key: Key('redo estimate'),
        icon: Icons.undo,
        title: 'Redo estimate'.i18n,
        onPressed: () => user.setGaveEstimate(false),
        secondary: true,
      ),
    ];
  }

  String textForEstimate(double estimate) {
    if (estimate == 0) {
      return 'No change'.i18n;
    }
    String estimateString = '${(estimate * 100).abs().toStringAsFixed(1)}%';

    if (estimate > 0) {
      return 'I\'m moving %s more.'.i18n.fill([estimateString]);
    }
    return 'I\'m moving %s less.'.i18n.fill([estimateString]);
  }
}
