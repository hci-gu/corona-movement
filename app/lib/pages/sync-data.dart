import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/widgets/steps-estimate.dart';

class SyncData extends HookWidget {
  @override
  Widget build(BuildContext context) {
    OnboardingModel onboarding = useModel(onboardingAtom);

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
              onboarding.dataChunks != null && onboarding.dataChunks.length > 0
                  ? 'Uploading your steps...'
                  : 'Upload done',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            if (onboarding.dataChunks != null &&
                onboarding.dataChunks.length > 0)
              Text(
                'Syncing: ${onboarding.dataChunks.length} uploads left',
                textAlign: TextAlign.center,
              ),
            StepsEstimate(),
          ],
        ),
      ),
    );
  }
}
