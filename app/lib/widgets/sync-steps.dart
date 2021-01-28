import 'package:wfhmovement/i18n/widgets/sync-steps.i18n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:wfhmovement/models/garmin.dart';
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
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
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
          StyledButton(
            icon: Icons.sync,
            title: 'Sync steps'.i18n,
            onPressed: () {
              globalAnalytics.sendEvent('syncSteps');
              syncSteps();
            },
          ),
        ],
      ),
    );
  }
}
