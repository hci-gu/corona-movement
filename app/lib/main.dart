// import 'package:activity_fetcher/providers.dart';
import 'package:activity_fetcher/recoil.dart';
import 'package:activity_fetcher/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    print(
        "Native called background task: $task"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());

  Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
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
        title: 'Coronamovement',
        theme: ThemeData(
          fontFamily: 'Poppins',
          primarySwatch: Colors.amber,
        ),
        debugShowCheckedModeBanner: false,
        home: Home(),
      ),
    );
  }
}

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var userId = useModel(userIdSelector);
    var pendingHealthDataPoints = useModel(pendingDataPointsSelector);
    var init = useAction(initAction);
    var getSteps = useAction(getStepsAction);
    useMemoized(() {
      init();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Coronamovement'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(25),
              child: SvgPicture.asset(
                'assets/svg/activity.svg',
                height: 150,
              ),
            ),
            Text(
              'Logged in as: $userId',
              textAlign: TextAlign.center,
            ),
            if (pendingHealthDataPoints != null)
              Text(
                'Syncing data, ${pendingHealthDataPoints.length} chunks left...',
                textAlign: TextAlign.center,
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => getSteps(),
        tooltip: 'Increment',
        child: Icon(Icons.cloud_upload),
      ),
    );
  }
}
