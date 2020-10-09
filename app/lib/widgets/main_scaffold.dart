import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:wfhmovement/style.dart';

class MainScaffold extends StatelessWidget {
  Widget child;
  Widget appBar;

  MainScaffold({@required this.child, this.appBar}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      body: child,
    );
  }
}
