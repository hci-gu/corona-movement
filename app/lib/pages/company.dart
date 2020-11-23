import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/button.dart';
import 'package:wfhmovement/widgets/company_code.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';

class CompanyPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      appBar: AppWidgets.appBar(context, 'Join company', false),
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
          'If you have a code you can enter it here to join a company.\n\nIf you\'re interested in trying out this feature within your company feel free to contact us at sebastian.andreasson@ait.gu.se',
        ),
        GroupCode(
          showInfo: false,
        ),
      ],
    );
  }
}
