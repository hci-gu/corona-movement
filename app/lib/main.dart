import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:wfhmovement/global-analytics.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/pages/home.dart';
import 'package:wfhmovement/pages/onboarding/introduction.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/pages/sync-data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz;

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    print("Native called background task: $task");
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  FirebaseAnalytics analytics = FirebaseAnalytics();
  globalAnalytics.init(analytics);

  runApp(App(analytics));

  Workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
}

class App extends StatelessWidget {
  final FirebaseAnalytics analytics;

  App(this.analytics);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => StateStore(),
      child: MaterialApp(
        title: 'Work from home movement',
        theme: ThemeData(
          fontFamily: 'Poppins',
          primarySwatch: Colors.amber,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color.fromARGB(255, 250, 250, 250),
          body: ScreenSelector(),
        ),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
      ),
    );
  }
}

class ScreenSelector extends HookWidget {
  @override
  Widget build(BuildContext context) {
    OnboardingModel onboarding = useModel(onboardingAtom);
    User user = useModel(userAtom);
    var init = useAction(initAction);
    useEffect(() {
      init();
      return;
    }, []);

    if (!user.inited)
      return Center(
        child: CircularProgressIndicator(),
      );

    if ((user.id == null || !onboarding.done) && !onboarding.uploading) {
      return Introduction();
    }
    if (onboarding.uploading || !user.gaveEstimate) {
      return SyncData();
    }
    return Home();
  }
}
