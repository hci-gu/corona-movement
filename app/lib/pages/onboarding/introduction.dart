import 'package:i18n_extension/i18n_widget.dart';
import 'package:wfhmovement/api/responses.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/i18n.dart';

import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/pages/onboarding/date-picker.dart';
import 'package:wfhmovement/pages/onboarding/select-data-source.dart';
import 'package:wfhmovement/widgets/button.dart';
import 'package:wfhmovement/widgets/language-select.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';

import '../../style.dart';

class Introduction extends HookWidget {
  @override
  Widget build(BuildContext context) {
    OnboardingModel onboarding = useModel(onboardingAtom);
    User user = useModel(userAtom);

    return MainScaffold(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 60,
              ),
              shrinkWrap: true,
              children: <Widget>[
                Text(
                  'WFH Movement',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Have your movement patterns changed?'.i18n,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),
                  textAlign: TextAlign.center,
                ),
                Container(
                  margin: EdgeInsets.all(25),
                  child: SvgPicture.asset(
                    'assets/svg/remote_work.svg',
                    height: 150,
                  ),
                ),
                pickDateWidget(context, user)
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 0,
              child: LanguageSelect(),
            )
          ],
        ),
      ),
    );
  }

  Widget pickDateWidget(context, onboarding) {
    return Column(
      children: [
        SizedBox(
          height: 50,
        ),
        Text(
          'Begin by selecting the periods you have been working from home.'
              .i18n,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        StyledButton(
          icon: Icons.date_range,
          title: 'Select periods'.i18n,
          onPressed: () => _onSelectDatePressed(context, onboarding),
        ),
        SizedBox(height: 20),
        Image.asset(
          'assets/png/gu_logo.png',
          height: 80,
        )
      ],
    );
  }

  void _onSelectDatePressed(BuildContext context, User user) async {
    Function done = (BuildContext doneContext, List<DatePeriod> periods) {
      String title = 'Vill du fortsätta?'.i18n;
      String text =
          'If you\'re satisfied with the periods you added press \"Proceed\"'
              .i18n;
      if (periods.length == 0) {
        title = 'Lägg till en period';
        text =
            'You haven\'t added any periods\n\nYou add one by tapping a date in the calendar.'
                .i18n;
      } else if (periods.length == 1) {
        text +=
            '\n\nYou can add more periods by tapping outside the marked area in the calendar.'
                .i18n;
      }
      AppWidgets.showConfirmDialog(
        context: doneContext,
        title: title,
        text: text,
        completeButtonText: periods.length > 0 ? 'Proceed'.i18n : 'Ok',
        onComplete: () {
          if (periods.length > 0) {
            user.setAfterPeriods(periods);
            Navigator.of(doneContext).push(
              MaterialPageRoute(
                builder: (context) => SelectDataSource(),
                settings: RouteSettings(name: 'Select periods'),
              ),
            );
          }
        },
        onCancel: periods.length > 0 ? () {} : null,
      );
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DatePicker(
          onDone: done,
        ),
        settings: RouteSettings(name: 'Select periods'),
      ),
    );
  }
}
