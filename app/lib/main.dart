import 'dart:typed_data';

import 'package:feedback/feedback.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:wfhmovement/global-analytics.dart';
import 'package:wfhmovement/models/form_model.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/pages/home.dart';
import 'package:wfhmovement/pages/onboarding/introduction.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/pages/sync-data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:wfhmovement/api.dart' as api;
import 'package:image/image.dart' as img;
import 'package:wfhmovement/widgets/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  FirebaseAnalytics analytics = FirebaseAnalytics();
  globalAnalytics.init(analytics);

  runApp(App(analytics));
}

class App extends StatelessWidget {
  final FirebaseAnalytics analytics;

  App(this.analytics);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => StateStore(),
      child: BetterFeedback(
        backgroundColor: Colors.grey,
        drawColors: [Colors.red, Colors.green, Colors.blue, Colors.yellow],
        child: MaterialApp(
          title: 'Work from home movement',
          theme: ThemeData(
            fontFamily: 'Poppins',
            primarySwatch: Colors.amber,
          ),
          debugShowCheckedModeBanner: false,
          home: ScreenSelector(),
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
        ),
        onFeedback: (
          BuildContext context,
          String feedbackText, // the feedback from the user
          Uint8List feedbackScreenshot, // raw png encoded image data
        ) async {
          await api.feedback(feedbackText, feedbackScreenshot);
          BetterFeedback.of(context).hide();
        },
      ),
    );
  }
}

class ScreenSelector extends HookWidget {
  @override
  Widget build(BuildContext context) {
    OnboardingModel onboarding = useModel(onboardingAtom);
    FormModel form = useModel(formAtom);
    User user = useModel(userAtom);
    var init = useAction(initAction);
    useEffect(() {
      init();
      return;
    }, []);

    if (!user.inited) {
      return MainScaffold(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if ((user.id == null || !onboarding.done) && !onboarding.uploading) {
      return Introduction();
    }
    if (onboarding.uploading || !user.gaveEstimate || !form.uploaded) {
      return SyncData();
    }
    return Home();
  }
}
