import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/button.dart';
import 'package:wfhmovement/widgets/garmin-login.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';

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

    return MainScaffold(
      appBar: AppWidgets.appBar(context, onboarding.dataSource, false),
      child: _body(context, onboarding),
    );
  }

  Widget _body(BuildContext context, OnboardingModel onboarding) {
    var consent = useState(false);
    var getHealthAuthorization = useAction(getHealthAuthorizationAction);
    var register = useAction(registerAction);
    var uploadSteps = useAction(uploadStepsAction);

    return Center(
      child: Container(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 50),
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(25),
              child: SvgPicture.asset(
                'assets/svg/access.svg',
                height: 150,
              ),
            ),
            if (!onboarding.authorized &&
                !onboarding.fetching &&
                onboarding.availableData.length == 0)
              _getAccess(onboarding, getHealthAuthorization),
            if (onboarding.availableData.length > 500)
              _hasData(context, onboarding, register, consent, uploadSteps),
            if (onboarding.authorized &&
                onboarding.availableData.length <= 500 &&
                !onboarding.fetching)
              _noData(context, onboarding, getHealthAuthorization),
            if (onboarding.fetching)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getAccess(
      OnboardingModel onboarding, Function getHealthAuthorization) {
    return Column(
      children: [
        Text(
            'To proceeed you must grant access for us to collect data from ${onboarding.dataSource}.'),
        SizedBox(height: 25),
        if (onboarding.dataSource == 'Garmin') GarminLogin(),
        StyledButton(
          icon: Icon(Icons.check),
          title: 'Give access',
          onPressed: () async {
            getHealthAuthorization();
          },
        ),
      ],
    );
  }

  void _authorizeFitbit() async {
    final result = await FlutterWebAuth.authenticate(
      url:
          'https://www.fitbit.com/oauth2/authorize?response_type=token&client_id=22BSFZ&redirect_uri=https%3A%2F%2Fapi.mycoronamovement.com%2Ffitbit%2Fcallback&scope=activity&expires_in=604800',
      callbackUrlScheme: 'wfhmovement',
    );
  }

  Widget _hasData(BuildContext context, OnboardingModel onboarding,
      Function register, ValueNotifier consent, Function uploadSteps) {
    return Column(
      children: [
        Container(
          child: Text(
            'Found data from ${onboarding.initialDataDate.toString().substring(0, 10)}',
          ),
        ),
        SizedBox(height: 20),
        Text(
          'This is part of a design reserach project on how we can design for living in a pandemic, during a pandemic. For this, we want to collect some data.\n\nThe data we collect through this app is the step data, associated with a device id, as well as interaction logs. The research is exploratory, but we currently have two primary research questions. 1) have and if so how have people’s movement patterns been affected by the ongoing pandemic. and 2) how can we design for wellbeing during the pandemic.\n\nIf you agree to us gathering your data, please tick the checkbox below and get started.',
          style: TextStyle(fontSize: 12),
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
              child: Text(
                'I agree to share my data with you.',
                maxLines: 2,
              ),
            )
          ],
        ),
        SizedBox(height: 20),
        Opacity(
          opacity: consent.value ? 1 : 0.5,
          child: StyledButton(
            icon: Icon(Icons.directions_run),
            title: 'Get started!',
            onPressed: () async {
              if (!consent.value) return;
              await register();
              uploadSteps();
              while (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _noData(BuildContext context, OnboardingModel onboarding,
      Function getHealthAuthorization) {
    String description =
        'You don\'t have any saved steps from ${onboarding.dataSource} or failed to give this app access to your health data. Try again after reviewing access to health data in your phone settings or go back and select another data source or proceed without steps.';
    if (onboarding.availableData.length > 0) {
      description =
          'You don\'t have enough steps saved to make any comparison, you need at least a couple of days before and after your set date for working from home. Go back and select another data source or proceed without steps.';
    }

    return Column(
      children: [
        Text(description),
        SizedBox(height: 25),
        StyledButton(
          icon: Icon(Icons.arrow_back),
          title: 'Go back',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        SizedBox(height: 25),
        if (onboarding.availableData.length == 0)
          StyledButton(
            icon: Icon(Icons.refresh),
            title: 'Try again',
            onPressed: () => getHealthAuthorization(),
          ),
      ],
    );
  }
}
