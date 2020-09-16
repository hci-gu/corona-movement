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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BetterFeedback.of(context).show();
          AppWidgets.showAlert(
            context,
            'Give feedback',
            'Describe a potential bug or write below to suggest some new feature. You can also toggle between Navigate/Draw to the right if you want to highlight something',
          );
        },
        child: Icon(Icons.feedback_outlined),
      ),
    );
  }
}
