import 'package:wfhmovement/i18n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:wfhmovement/models/garmin.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/button.dart';

import '../global-analytics.dart';
import 'garmin-login.dart';

class SyncSteps extends HookWidget {
  @override
  Widget build(BuildContext context) {
    User user = useModel(userAtom);
    OnboardingModel onboarding = useModel(onboardingAtom);
    var syncSteps = useAction(syncStepsAction);
    var garminSyncSteps = useAction(garminSyncStepsAction);
    var getUserLatestUpload = useAction(getUserLatestUploadAction);

    useEffect(() {
      if (user.id != 'all') {
        getUserLatestUpload();
      }
      return;
    }, []);

    if (user.loading) {
      return Column(
        children: [
          if (onboarding.dataChunks.isNotEmpty)
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                  'Syncing steps, ${onboarding.dataChunks.length} uploads left'),
            ),
          Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
      );
    }
    int diff = DateTime.now()
        .difference(DateTime.parse(user.latestUploadDate.toIso8601String()))
        .inHours;
    bool syncedRecently = user.lastSync != null &&
        DateTime.now().difference(user.lastSync).inMinutes < 5;
    if (diff <= 1 || syncedRecently) {
      return Container();
    }
    bool fitbitRatelimited =
        user.dataSource == 'Fitbit' && user.rateLimitTimeStamp != null;

    if (user.awaitingDataSource) {
      return Column(
        children: [
          Text('Login with your Garmin credentials'.i18n),
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
    var dateString =
        DateFormat('yyyy-MM-dd HH:mm').format(user.latestUploadDate);

    return Center(
      child: Column(
        children: [
          AppWidgets.chartDescription(
            'You have steps up until %s,\n press the button below to sync them.'
                .i18n
                .fill([dateString]),
          ),
          if (fitbitRatelimited) _fitbitRateLimit(user),
          StyledButton(
            icon: Icons.sync,
            title: 'Sync steps'.i18n,
            onPressed: () {
              if (fitbitRatelimited) {
                // return;
              }
              globalAnalytics.sendEvent('syncSteps');
              syncSteps();
            },
          ),
        ],
      ),
    );
  }

  Widget _fitbitRateLimit(User user) {
    int minutesLeft =
        DateTime.now().difference(user.rateLimitTimeStamp).inMinutes;

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
            'Fitbit requires you to wait 1 hour between each time you fetch more than 150 days worth of steps.'
                .i18n,
          ),
          SizedBox(height: 10),
          Text('You can try again in %s minutes.'.i18n.fill([minutesLeft]))
        ],
      ),
    );
  }
}
