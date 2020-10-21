import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wfhmovement/global-analytics.dart';
import 'package:wfhmovement/models/garmin.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';
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
                if (user.id != 'all')
                  ..._userWidgets(context, user, updateUserCompareDate),
                if (user.id != 'all')
                  ..._loggedInUserWidgets(
                      context, user, syncSteps, garminSyncSteps, deleteUser),
                _appInformation(context),
                if (user.id != 'all' && user.id != null)
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(25),
                      child: Text('User id: ${user.id}'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _userWidgets(BuildContext context, user, updateUserCompareDate) {
    return [
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
          icon: Icons.date_range,
          title: 'Change date',
          onPressed: () => _onChangeDatePressed(
            context,
            user,
            updateUserCompareDate,
          ),
        ),
      ),
      SizedBox(height: 40),
    ];
  }

  List<Widget> _loggedInUserWidgets(
      BuildContext context, User user, syncSteps, garminSyncSteps, deleteUser) {
    return [
      _syncStepsWidget(user, syncSteps, garminSyncSteps),
      // SizedBox(height: 15),
      // Center(
      //   child: StyledButton(
      //     icon: Icon(Icons.add),
      //     title: 'Add data source',
      //     onPressed: () {
      //       globalAnalytics.observer.analytics.logEvent(name: 'addDataSource');
      //       Navigator.of(context).push(
      //         MaterialPageRoute(
      //           builder: (context) => SelectDataSource(),
      //           settings: RouteSettings(name: 'Select data source'),
      //         ),
      //       );
      //     },
      //   ),
      // ),
      SizedBox(height: 15),
      Center(
        child: StyledButton(
          icon: Icons.delete,
          title: 'Delete data',
          onPressed: () => _onDeleteUserPressed(context, deleteUser),
          danger: true,
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
            icon: Icons.sync,
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
            icon: Icons.sync,
            title: 'Sync steps',
            onPressed: () {
              globalAnalytics.sendEvent('syncSteps');
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
    globalAnalytics.sendEvent('openChangeCompareDate');

    var date = await showDatePicker(
      context: context,
      initialDate: compareDate,
      firstDate: DateTime.parse('2010-01-01'),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      globalAnalytics.sendEvent('changeCompareDate');
      user.setCompareDate(DateTime(date.year, date.month, date.day));
      updateUserCompareDate();
    }
  }

  Widget _appInformation(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 25),
        Text(
          'The Work From Home app was developed for research purposes by the Division of Human Computer Interaction at the Department of Applied Information Technology, University of Gothenburg, Sweden.',
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(height: 10),
        Text(
          'By picking a date where you started working from home, you will be able to explore whether your movement patterns have changed since you started working from home. The app visualizes your movement in the form of steps data from your phone, through Apple Health, Google fitness or Garmin.',
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(height: 10),
        Text(
          'Read more about the project here:',
          style: TextStyle(fontSize: 12),
        ),
        InkWell(
          child: Text('https://hci-gu.github.io/wfh-movement'),
          onTap: () async {
            const url = 'https://hci-gu.github.io/wfh-movement';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
        ),
        SizedBox(height: 20),
        Image.asset(
          'assets/png/gu_logo.png',
          height: 80,
        )
      ],
    );
  }

  void _onDeleteUserPressed(BuildContext parentContext, deleteUser) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm',
          ),
          content: Text(
            'Are you sure you want to delete your data?\n\nThis will remove all data from the app, and from our servers. You will no longer praticipate in the research project.\n\nIf you want to use the app again, you are welcome to do so.',
          ),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                globalAnalytics.sendEvent('deleteAccount');
                deleteUser();
                Navigator.of(context).pop();
                Navigator.of(parentContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
