import 'package:wfhmovement/garmin_client.dart';
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

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    print("Native called background task: $task");
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());

  Workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
}

class MyApp extends StatelessWidget {
  MyApp();
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

    if (user.id == null || !onboarding.gaveConsent) {
      return Introduction();
    }
    if (onboarding.availableData.length > 0 ||
        onboarding.dataChunks.length > 0) {
      return SyncData();
    }
    return Home();
  }
}
