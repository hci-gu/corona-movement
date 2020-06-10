import 'package:health/health.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/widgets/button.dart';

class DataSource extends HookWidget {
  @override
  Widget build(BuildContext context) {
    OnboardingModel onboarding = useModel(onboardingAtom);
    var getAvailableSteps = useAction(getAvailableStepsAction);

    useEffect(() {
      if (onboarding.authorized) {
        getAvailableSteps();
      }
      return;
    }, [onboarding.authorized]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          onboarding.dataSource,
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _body(context, onboarding),
    );
  }

  Widget _body(BuildContext context, OnboardingModel onboarding) {
    var getHealthAuthorization = useAction(getHealthAuthorizationAction);
    var register = useAction(registerAction);
    var consent = useState(true);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 25, vertical: 50),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(25),
              child: SvgPicture.asset(
                'assets/svg/access.svg',
                height: 150,
              ),
            ),
            if (!onboarding.authorized) _getAccess(getHealthAuthorization),
            if (onboarding.availableData.length > 0)
              _hasData(context, onboarding, register, consent)
          ],
        ),
      ),
    );
  }

  Widget _getAccess(Function getHealthAuthorization) {
    return Column(
      children: [
        Text('To proceed you need to provide access'),
        SizedBox(height: 25),
        StyledButton(
          icon: Icon(Icons.check),
          title: 'Give access',
          onPressed: () => getHealthAuthorization(),
        ),
      ],
    );
  }

  Widget _hasData(BuildContext context, OnboardingModel onboarding,
      Function register, ValueNotifier consent) {
    HealthDataPoint point = onboarding.availableData[0];
    DateTime from = DateTime.fromMillisecondsSinceEpoch(point.dateFrom);

    return Column(
      children: [
        Container(
          child: Text('Found data from ${from.toString().substring(0, 10)}'),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: consent.value,
              onChanged: (value) {
                consent.value = value;
              },
            ),
            Container(
              width: 200,
              child: Text(
                'I want to participate in a study with my data',
                maxLines: 3,
              ),
            )
          ],
        ),
        SizedBox(height: 20),
        StyledButton(
          icon: Icon(Icons.directions_run),
          title: 'Get started!',
          onPressed: () async {
            await register();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
