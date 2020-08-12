import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:wfhmovement/global-analytics.dart';
import 'package:wfhmovement/models/garmin.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/pages/onboarding/select-data-source.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/button.dart';
import 'package:wfhmovement/widgets/garmin-login.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);
    var getUserLatestUpload = useAction(getUserLatestUploadAction);
    var garminSyncSteps = useAction(garminSyncStepsAction);

    useEffect(() {
      getUserLatestUpload();
    }, []);
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
                  child: user.loading
                      ? CircularProgressIndicator()
                      : StyledButton(
                          icon: Icon(Icons.date_range),
                          title: 'Change date',
                          onPressed: () => _onChangeDatePressed(
                            context,
                            user,
                            updateUserCompareDate,
                          ),
                        ),
                ),
                SizedBox(height: 40),
                if (user.id != 'all')
                  _syncStepsWidget(user, syncSteps, garminSyncSteps),
                SizedBox(height: 15),
                Center(
                  child: StyledButton(
                    icon: Icon(Icons.add),
                    title: 'Add data source',
                    onPressed: () {
                      globalAnalytics.observer.analytics
                          .logEvent(name: 'addDataSource');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SelectDataSource(),
                          settings: RouteSettings(name: 'Select data source'),
                        ),
                      );
                    },
                  ),
                ),
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

  Widget _syncStepsWidget(User user, syncSteps, garminSyncSteps) {
    if (user.awaitingDataSource) {
      return Column(
        children: [
          Text('Login with your Garmin to credentials'),
          GarminLogin(),
          user.loading
              ? CircularProgressIndicator()
              : StyledButton(
                  icon: Icon(Icons.sync),
                  title: 'Sync Garmin',
                  onPressed: () {
                    garminSyncSteps();
                  },
                )
        ],
      );
    }
    return Center(
      child: Column(
        children: [
          user.loading
              ? CircularProgressIndicator()
              : StyledButton(
                  icon: Icon(Icons.sync),
                  title: 'Sync steps',
                  onPressed: () {
                    globalAnalytics.observer.analytics
                        .logEvent(name: 'syncSteps');
                    syncSteps();
                  },
                ),
          if (!user.loading)
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'Last sync: ${DateFormat('yyyy-MM-dd HH:mm').format(user.latestUploadDate)}',
              ),
            ),
        ],
      ),
    );
  }

  void _onChangeDatePressed(
      BuildContext context, user, updateUserCompareDate) async {
    DateTime compareDate = user.compareDate;
    globalAnalytics.observer.analytics.logEvent(name: 'openChangeCompareDate');

    var date = await showDatePicker(
      context: context,
      initialDate: compareDate,
      firstDate: compareDate.subtract(Duration(days: 120)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      globalAnalytics.observer.analytics.logEvent(name: 'changeCompareDate');
      user.setCompareDate(DateTime(date.year, date.month, date.day));
      updateUserCompareDate();
    }
  }
}
