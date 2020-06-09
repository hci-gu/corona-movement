import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/pages/onboarding/select-data-source.dart';

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    OnboardingModel onboarding = useModel(onboardingAtom);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Find out how your movement patterns have changed.',
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              margin: EdgeInsets.all(25),
              child: SvgPicture.asset(
                'assets/svg/remote_work.svg',
                height: 150,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Interested? Start by picking the day you started working from home',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            OutlineButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.date_range,
                    color: Colors.yellow[800],
                    size: 24.0,
                  ),
                  SizedBox(width: 10),
                  Text('Select date')
                ],
              ),
              onPressed: () async {
                var date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse('2020-03-18'),
                  firstDate: DateTime.parse('2020-01-01'),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  onboarding.setDate(date);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SelectDataSource(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
