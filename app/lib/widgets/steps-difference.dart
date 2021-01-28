import 'package:wfhmovement/i18n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/models/user_model.dart';
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
    User user = useModel(userAtom);

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
          _textForDiff(diff, user),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: share ? 14 : 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      ]),
    );
  }

  String _textForDiff(diff, User user) {
    String diffText = double.parse(diff) > 0 ? 'more'.i18n : 'less'.i18n;
    if (user.id == 'all') {
      if (diff == null) return 'People\'s movement hasn\'t changed.'.i18n;
      return 'People are moving %s %s.'.i18n.fill(['$diff%', diffText]);
    }

    if (share && diff == null) {
      return 'My movement hasn\'t changed.'.i18n;
    }
    if (share) {
      return 'I\'m moving %s %s.'.i18n.fill(['$diff%', diffText]);
    }
    return 'You\'re moving %s %s.'.i18n.fill(['$diff%', diffText]);
  }
}
