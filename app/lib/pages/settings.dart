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
import 'package:wfhmovement/widgets/main_scaffold.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);
    var getUserLatestUpload = useAction(getUserLatestUploadAction);
    var garminSyncSteps = useAction(garminSyncStepsAction);
    var deleteUser = useAction(deleteUserAction);

    useEffect(() {
      if (user.id != 'all') {
        getUserLatestUpload();
      }
      return;
    }, []);
    useEffect(() {
      if (user.id == null) {
        Navigator.of(context).pop();
      }
      return;
    }, [user.id]);
    var updateUserCompareDate = useAction(updateUserCompareDateAction);
    var syncSteps = useAction(syncStepsAction);

    if (user.loading) {
      return MainScaffold(
        appBar: AppWidgets.appBar(context, 'Settings', false),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MainScaffold(
      appBar: AppWidgets.appBar(context, 'Settings', false),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(25),
              children: [
                if (user.compareDate != null)
                  Text(
                    'You started working from home on ${user.compareDate.toIso8601String().substring(0, 10)}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                SizedBox(height: 20),
                Center(
                  child: StyledButton(
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
                  ..._loggedInUserWidgets(
                      context, user, syncSteps, garminSyncSteps, deleteUser),
                if (user.id == 'all') ..._noUserWidgets(context, deleteUser)
              ],
            ),
          ),
          if (user.id != 'all' && user.id != null)
            Container(
              padding: EdgeInsets.all(25),
              child: Text('User: ${user.id}'),
            ),
        ],
      ),
    );
  }

  List<Widget> _noUserWidgets(BuildContext context, deleteUser) {
    return [
      Center(
        child: StyledButton(
          icon: Icon(Icons.redo),
          title: 'Redo introduction',
          onPressed: () {
            deleteUser();
            Navigator.of(context).pop();
          },
        ),
      ),
    ];
  }

  List<Widget> _loggedInUserWidgets(
      BuildContext context, User user, syncSteps, garminSyncSteps, deleteUser) {
    return [
      _syncStepsWidget(user, syncSteps, garminSyncSteps),
      SizedBox(height: 15),
      Center(
        child: StyledButton(
          icon: Icon(Icons.add),
          title: 'Add data source',
          onPressed: () {
            globalAnalytics.observer.analytics.logEvent(name: 'addDataSource');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SelectDataSource(),
                settings: RouteSettings(name: 'Select data source'),
              ),
            );
          },
        ),
      ),
      SizedBox(height: 15),
      Center(
        child: StyledButton(
          icon: Icon(Icons.delete),
          title: 'Delete account',
          onPressed: () => _onDeleteUserPressed(context, deleteUser),
        ),
      ),
    ];
  }

  Widget _syncStepsWidget(User user, syncSteps, garminSyncSteps) {
    if (user.awaitingDataSource) {
      return Column(
        children: [
          Text('Login with your Garmin to credentials'),
          GarminLogin(),
          StyledButton(
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
          StyledButton(
            icon: Icon(Icons.sync),
            title: 'Sync steps',
            onPressed: () {
              globalAnalytics.observer.analytics.logEvent(name: 'syncSteps');
              syncSteps();
            },
          ),
          if (user.latestUploadDate != null)
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

  void _onDeleteUserPressed(BuildContext context, deleteUser) async {
    Widget cancelButton = FlatButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget confirmButton = FlatButton(
      child: Text('Yes'),
      onPressed: () {
        globalAnalytics.observer.analytics.logEvent(name: 'deleteAccount');
        deleteUser();
        Navigator.of(context).pop();
      },
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm',
          ),
          content: Text(
            'Are you sure you want to delete your account and data?',
          ),
          actions: [
            cancelButton,
            confirmButton,
          ],
        );
      },
    );
  }
}
