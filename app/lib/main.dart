import 'package:mycoronamovement/models/user_model.dart';
import 'package:mycoronamovement/pages/charts.dart';
import 'package:mycoronamovement/pages/home.dart';
import 'package:mycoronamovement/models/recoil.dart';
import 'package:mycoronamovement/pages/sync-data.dart';
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
        title: 'Coronamovement',
        theme: ThemeData(
          fontFamily: 'Poppins',
          primarySwatch: Colors.amber,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text('Coronamovement'),
          ),
          body: ScreenSelector(),
        ),
      ),
    );
  }
}

class ScreenSelector extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var userState = useModel(userStateSelector);
    var init = useAction(initAction);
    useMemoized(() {
      init();
    });

    switch (userState) {
      case 'home':
        return Home();
      case 'sync-data':
        return SyncData();
      case 'charts':
        return Charts();
      default:
        return Center(
          child: CircularProgressIndicator(),
        );
    }
  }
}
