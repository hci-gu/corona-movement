import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/button.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';

class NoSteps extends HookWidget {
  @override
  Widget build(BuildContext context) {
    OnboardingModel onboarding = useModel(onboardingAtom);

    return MainScaffold(
      appBar: AppWidgets.appBar(context, 'No steps', false),
      child: _body(context, onboarding),
    );
  }

  Widget _body(BuildContext context, OnboardingModel onboarding) {
    var proceedWithoutSteps = useAction(proceedWithoutStepsAction);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 25, vertical: 50),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(25),
              child: SvgPicture.asset(
                'assets/svg/empty.svg',
                height: 150,
              ),
            ),
            AppWidgets.chartDescription(
              'If you don\'t have any steps saved you can still proceed without uploading to just explore others results.',
            ),
            StyledButton(
              title: 'Proceed',
              onPressed: () {
                proceedWithoutSteps();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }
}
