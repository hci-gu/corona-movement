import 'package:wfhmovement/i18n/onboarding/select-data-source.i18n.dart';

import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/pages/onboarding/data-source.dart';
import 'package:wfhmovement/pages/onboarding/no-steps.dart';
import 'package:wfhmovement/style.dart';
import 'package:wfhmovement/widgets/main_scaffold.dart';

class SelectDataSource extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      appBar: AppWidgets.appBar(context, 'Select data source'.i18n, false),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 25, bottom: 50, left: 25, right: 25),
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(25),
          child: SvgPicture.asset(
            'assets/svg/data_sources.svg',
            height: 150,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        _textInfo(context),
        SizedBox(height: 20),
        Text(
          'Please select where you keep your step data.'.i18n,
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 20,
        ),
        ..._dataSources(context),
        Card(
          child: ListTile(
            title: Text(
              'I don\'t have any steps saved.'.i18n,
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NoSteps(),
                  settings: RouteSettings(name: 'No steps'),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _textInfo(BuildContext context) {
    return InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(5),
            child: Icon(Icons.info_outline),
          ),
          Expanded(
            child: Text(
              'For us to tell you how your moment patterns have changed we need access to your step data.'
                  .i18n,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      onTap: () => AppWidgets.showAlert(
        context,
        'Selecting a data source'.i18n,
        'The app will fetch data from a source where you may have step data. Some people with android use google fitness (you might not even know about it). People with iOS devices typically have apple health that automatically record movement data. Some people use Garmin. If you do not have any historical data, you may use the app anyway to compare yourself with others.'
            .i18n,
      ),
    );
  }

  List<Widget> _dataSources(BuildContext context) {
    OnboardingModel onboarding = useModel(onboardingAtom);

    return OnboardingModel.dataSources.map((dataSource) {
      return Card(
        child: ListTile(
          leading: _assetForDataSource(dataSource),
          title: Text(dataSource),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            onboarding.setDataSource(dataSource);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DataSource(),
                settings: RouteSettings(name: 'Datasource $dataSource'),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _assetForDataSource(String dataSource) {
    switch (dataSource) {
      case 'Google fitness':
        return Container(
          width: 40,
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Image(image: AssetImage('assets/png/google_fit_logo.png')),
        );
      case 'Apple health':
        return Container(
          width: 40,
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Image(image: AssetImage('assets/png/apple_health_logo.png')),
        );
      case 'Garmin':
        return Container(
          width: 40,
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Image(image: AssetImage('assets/png/garmin_logo.png')),
        );
      case 'Fitbit':
        return Container(
          width: 40,
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Image(image: AssetImage('assets/png/fitbit_logo.png')),
        );
      default:
        return null;
    }
  }
}
