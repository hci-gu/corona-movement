import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wfhmovement/models/app_model.dart';
import 'package:wfhmovement/models/recoil.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final Widget appBar;
  final bool displaySnackbars;

  MainScaffold({
    Key key,
    @required this.child,
    this.appBar,
    this.displaySnackbars = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      body: displaySnackbars ? SnackbarDisplayer(child: child) : child,
    );
  }
}

class SnackbarDisplayer extends HookWidget {
  final Widget child;

  SnackbarDisplayer({@required this.child}) : super();

  @override
  Widget build(BuildContext context) {
    AppModel appModel = useModel(appModelAtom);

    useEffect(() {
      if (appModel.snackMessage != null) {
        final snackBar = SnackBar(
          content: Text(appModel.snackMessage),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        );
        scheduleMicrotask(() {
          Scaffold.of(context).showSnackBar(snackBar);
        });
        appModel.setSnackMessage(null);
      }
      return;
    }, [appModel.snackMessage]);

    return child;
  }
}
