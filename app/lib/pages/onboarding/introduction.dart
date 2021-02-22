import 'package:i18n_extension/i18n_widget.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/i18n.dart';

import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/pages/onboarding/date-picker.dart';
import 'package:wfhmovement/pages/onboarding/select-data-source.dart';
import 'package:wfhmovement/widgets/button.dart';
import 'package:wfhmovement/widgets/language-select.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';

class Introduction extends HookWidget {
  @override
  Widget build(BuildContext context) {
    OnboardingModel onboarding = useModel(onboardingAtom);

    return DatePicker();

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
                pickDateWidget(context, onboarding)
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
          'Begin by picking the day you started working from home.'.i18n,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        StyledButton(
          icon: Icons.date_range,
          title: 'Select date'.i18n,
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

  void _onSelectDatePressed(BuildContext context, onboarding) async {
    var date = await showDatePicker(
      locale: I18n.of(context).locale,
      context: context,
      initialDate: DateTime.parse('2020-03-01'),
      firstDate: DateTime.parse('2010-01-01'),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      onboarding.setDate(DateTime(date.year, date.month, date.day));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SelectDataSource(),
          settings: RouteSettings(name: 'Select datasource'),
        ),
      );
    }
  }
}
