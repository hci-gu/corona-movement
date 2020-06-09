import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wfhmovement/pages/onboarding/data-source.dart';

class SelectDataSource extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select data source',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 50),
      child: Column(
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
          Text(
            'To continue you need to select where you have historical data of your steps.',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(
            height: 50,
          ),
          ..._dataSources(context),
        ],
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
      default:
        return null;
    }
  }
}
