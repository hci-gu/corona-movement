import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'dart:ui' as ui;
import 'package:path/path.dart' show join;
import 'package:wfhmovement/global-analytics.dart';

import 'button.dart';

class ShareButton extends StatelessWidget {
  GlobalKey paintKey = new GlobalKey();
  final String text;
  final String subject;
  final List<Widget> widgets;
  final String screen;

  ShareButton({
    Key key,
    @required this.widgets,
    @required this.text,
    @required this.subject,
    this.screen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: StyledButton(
          icon: Icon(Icons.share),
          title: 'Share',
          onPressed: () => _presentShareView(context),
        ),
      ),
    );
  }

  _presentShareView(BuildContext context) {
    globalAnalytics.sendEvent('openShare', {'screen': screen});
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Share preview'),
          contentPadding: EdgeInsets.all(10),
          content: RepaintBoundary(
            key: paintKey,
            child: Container(
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(maxHeight: 360),
              child: Column(
                children: widgets,
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
                globalAnalytics.sendEvent('share', {'screen': screen});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _onSharePressed(BuildContext context) async {
    RenderRepaintBoundary boundary = paintKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
    );
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();

    final path = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );

    final file = File(path);
    await file.writeAsBytes(pngBytes);

    await Share.shareFiles(
      [path],
      text: text,
      subject: subject,
    );
  }
}
