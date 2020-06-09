import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

class SyncData extends HookWidget {
  @override
  Widget build(BuildContext context) {
    OnboardingModel onboarding = useModel(onboardingAtom);
    var uploadSteps = useAction(uploadStepsAction);
    useMemoized(() {
      uploadSteps();
    });

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(25),
              child: SvgPicture.asset(
                'assets/svg/data.svg',
                height: 150,
              ),
            ),
            Text(
              'Analyserar din hälsodata...',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            if (onboarding.availableData != null &&
                onboarding.availableData.length > 0)
              Text(
                'Synkar: ${onboarding.availableData.length} uppladdningar kvar',
                textAlign: TextAlign.center,
              )
          ],
        ),
      ),
    );
  }
}
