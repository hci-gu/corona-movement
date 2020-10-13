import 'package:wfhmovement/global-analytics.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/pages/onboarding/select-data-source.dart';
import 'package:wfhmovement/widgets/button.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';

class Introduction extends HookWidget {
  @override
  Widget build(BuildContext context) {
    OnboardingModel onboarding = useModel(onboardingAtom);
    User user = useModel(userAtom);
    var code = useTextEditingController(text: user.code);
    var unlock = useAction(unlockAction);
    var shouldUnlock = useAction(shouldUnlockAction);
    useEffect(() {
      shouldUnlock();
      return;
    }, []);

    return MainScaffold(
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 25),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Text(
                'WFH Movement',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              Text(
                'Have your movement patterns changed?',
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
              user.unlocked
                  ? pickDateWidget(context, onboarding)
                  : unlockWidget(user, code, unlock)
            ],
          ),
        ),
      ),
    );
  }

  Widget unlockWidget(user, code, unlock) {
    if (user.loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: [
        SizedBox(height: 50),
        Text(
          'This app is currently not available to everyone but can be unlocked with a code.',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
        ),
        TextField(
          controller: code,
          keyboardType: TextInputType.text,
          onChanged: (value) {
            user.setCode(value);
          },
          decoration: InputDecoration(
            hintText: 'Your code',
          ),
        ),
        SizedBox(height: 20),
        StyledButton(
          icon: user.loading
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ))
              : Icon(
                  user.code.length > 0 ? Icons.lock_open : Icons.lock_outline),
          title: 'Unlock',
          onPressed: () {
            unlock();
          },
        ),
        SizedBox(height: 20),
        Text('Interested in trying? Email:'),
        SizedBox(height: 5),
        SelectableText(
          'wfhmovement@gmail.com',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget pickDateWidget(context, onboarding) {
    return Column(
      children: [
        SizedBox(
          height: 50,
        ),
        Text(
          'Pick the day you started working from home, or other ways your life got turned up side down.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
        ),
        SizedBox(
          height: 20,
        ),
        StyledButton(
          icon: Icon(Icons.date_range),
          title: 'Select date',
          onPressed: () => _onSelectDatePressed(context, onboarding),
        ),
      ],
    );
  }

  void _onSelectDatePressed(BuildContext context, onboarding) async {
    var date = await showDatePicker(
      context: context,
      initialDate: DateTime.parse('2020-03-01'),
      firstDate: DateTime.parse(StepsModel.fromDate),
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
