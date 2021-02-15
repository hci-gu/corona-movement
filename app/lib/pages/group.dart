import 'package:wfhmovement/i18n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/group_code.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';

class GroupPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      appBar: AppWidgets.appBar(context: context, title: 'Join group'.i18n),
      displaySnackbars: true,
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20),
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(25),
          child: SvgPicture.asset(
            'assets/svg/company.svg',
            height: 150,
          ),
        ),
        AppWidgets.chartDescription(
          'If you have a code you can enter it here to join a group. This allows you to compare with others in the same group.\n\nIf you are interested in trying out this feature with your group, company or organization, feel free to contact us at sebastian.andreasson@ait.gu.se'
              .i18n,
        ),
        GroupCode(
          showInfo: false,
        ),
      ],
    );
  }
}
