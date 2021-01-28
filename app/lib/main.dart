import 'dart:typed_data';

import 'package:feedback/feedback.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:uni_links/uni_links.dart';
import 'package:wfhmovement/i18n.dart';
import 'package:wfhmovement/models/form_model.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/pages/home.dart';
import 'package:wfhmovement/pages/onboarding/introduction.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/pages/onboarding/sync-data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:wfhmovement/api/api.dart' as api;
import 'package:wfhmovement/widgets/main_scaffold.dart';

import 'api/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MyI18n.loadTranslations();
  tz.initializeTimeZones();
  try {
    String timezone = await FlutterNativeTimezone.getLocalTimezone();
    globalApiHandler.init(timezone);
  } catch (e) {}

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => StateStore(),
      child: BetterFeedback(
        backgroundColor: Colors.grey,
        drawColors: [Colors.red, Colors.green, Colors.blue, Colors.yellow],
        child: RefreshConfiguration(
          headerBuilder: () => WaterDropHeader(),
          headerTriggerDistance: 80.0,
          springDescription: SpringDescription(
            stiffness: 170,
            damping: 16,
            mass: 1.9,
          ),
          maxOverScrollExtent: 100,
          maxUnderScrollExtent: 0,
          enableScrollWhenRefreshCompleted: true,
          enableLoadingWhenFailed: true,
          enableBallisticLoad: true,
          child: I18n(
            initialLocale: Locale('sv', 'SE'),
            child: MaterialApp(
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                Locale('en', 'US'),
                Locale('sv', 'SE'),
              ],
              title: 'Work from home movement',
              theme: ThemeData(
                fontFamily: 'Poppins',
                primarySwatch: Colors.amber,
              ),
              debugShowCheckedModeBanner: false,
              home: ScreenSelector(),
            ),
          ),
        ),
        onFeedback: (
          BuildContext context,
          String feedbackText, // the feedback from the user
          Uint8List feedbackScreenshot, // raw png encoded image data
        ) async {
          BuildContext dialogContext;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              dialogContext = context;
              return Dialog(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text('Sending feedback'),
                    ],
                  ),
                ),
              );
            },
          );
          await api.feedback(feedbackText, feedbackScreenshot);
          Navigator.pop(dialogContext);
          BetterFeedback.of(context).hide();
          feedbackText = '';
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
    var joinGroup = useAction(joinGroupAction);
    useEffect(() {
      try {
        init();
      } catch (e) {}
      return;
    }, []);

    useEffect(() {
      var handleUri = (Uri uri) {
        if (uri != null) {
          String code = uri.queryParameters['code'];
          user.setGroupCode(code);
          if (user.id != null && user.group == null) {
            joinGroup();
            user.setDeeplinkOpen(true);
          } else if (user.id == null) {
            user.setDeeplinkOpen(true);
          }
        }
      };

      var asyncFunc = () async {
        try {
          Uri initialUri = await getInitialUri();
          handleUri(initialUri);
        } catch (e) {
          print('Failed to get initial uri.');
          print(e);
        }
        getUriLinksStream().listen((Uri uri) {
          handleUri(uri);
        }, onError: (err) {
          print('uri stream err ${err}');
        });
      };

      if (user.inited) asyncFunc();
      return;
    }, [user.inited]);

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
