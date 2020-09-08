import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'dart:ui' as ui;
import 'package:path/path.dart' show join;

import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/button.dart';
import 'package:wfhmovement/widgets/day-select.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';
import 'package:wfhmovement/widgets/steps-chart.dart';
import 'package:wfhmovement/widgets/steps-difference.dart';

class DetailedSteps extends HookWidget {
  GlobalKey _globalKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      appBar: AppWidgets.appBar(context, 'Detailed steps', true),
      child: ListView(
        padding: EdgeInsets.only(top: 25),
        children: [
          DaySelect(),
          StepsDifference(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Hero(
              tag: 'steps-chart',
              child: StepsChart(),
              flightShuttleBuilder: AppWidgets.flightShuttleBuilder,
            ),
          ),
          AppWidgets.chartDescription(
            'Above you can see how your activity have changed over a typical day before and after working from home.',
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: StyledButton(
                icon: Icon(Icons.share),
                title: 'Share',
                onPressed: () => _presentShareView(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _presentShareView(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Share your steps'),
          contentPadding: EdgeInsets.all(10),
          content: RepaintBoundary(
            key: _globalKey,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  StepsDifference(share: true),
                  StepsChart(share: true),
                  AppWidgets.chartDescription(
                    'Download the WFH movement app to try it out yourself.',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Share'),
              onPressed: () {
                _onSharePressed(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _onSharePressed(BuildContext context) async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();

    final path = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );

    final file = File(path);
    await file.writeAsBytes(pngBytes);

    await Share.shareFiles([path], text: 'Testing testing', subject: 'test');
  }
}
