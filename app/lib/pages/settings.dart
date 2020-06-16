import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/button.dart';
import 'package:wfhmovement/widgets/steps-difference.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);
    var updateUserCompareDate = useAction(updateUserCompareDateAction);
    var syncSteps = useAction(syncStepsAction);

    return Scaffold(
      appBar: AppWidgets.appBar(context, 'Settings', false),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(25),
              children: [
                Text(
                  'You started working from home on ${user.compareDate.toIso8601String().substring(0, 10)}',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: user.updating
                      ? CircularProgressIndicator()
                      : StyledButton(
                          icon: Icon(Icons.date_range),
                          title: 'Change date',
                          onPressed: () =>
                              _onPressed(context, user, updateUserCompareDate),
                        ),
                ),
                SizedBox(height: 40),
                if (user.id != 'all')
                  Center(
                    child: user.syncing
                        ? CircularProgressIndicator()
                        : StyledButton(
                            icon: Icon(Icons.sync),
                            title: 'Sync steps',
                            onPressed: () {
                              syncSteps();
                            },
                          ),
                  )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(25),
            child: Text('User: ${user.id}'),
          ),
        ],
      ),
    );
  }

  void _onPressed(BuildContext context, user, updateUserCompareDate) async {
    DateTime compareDate = user.compareDate;

    var date = await showDatePicker(
      context: context,
      initialDate: compareDate,
      firstDate: compareDate.subtract(Duration(days: 120)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      user.setCompareDate(DateTime(date.year, date.month, date.day));
      updateUserCompareDate();
    }
  }
}
