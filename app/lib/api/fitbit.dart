import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wfhmovement/api/responses.dart';

const API_URL = 'https://api.mycoronamovement.com';

class RatelimitExceeded implements Exception {
  DateTime timestamp;

  RatelimitExceeded(this.timestamp);
}

Future<List<Map<String, dynamic>>> getSteps(
    String accessToken, String date) async {
  var url = Uri.parse(
      'https://api.fitbit.com/1/user/-/activities/steps/date/$date/1d/15min.json');
  var response = await http.get(
    url,
    headers: {
      'authorization': 'Bearer $accessToken',
    },
  );
  if (response.statusCode == 429) {
    int secondsUntilReset =
        int.parse(response.headers['fitbit-rate-limit-reset']);
    throw new RatelimitExceeded(
        DateTime.now().subtract(Duration(seconds: secondsUntilReset)));
  }

  Map<String, dynamic> data = json.decode(response.body);
  List jsonlist = data['activities-steps-intraday']['dataset'];
  List<FitbitStep> steps =
      jsonlist.map((d) => FitbitStep.fromJson(date, d)).toList();

  return transformSteps(steps);
}

Future<List<FitbitDay>> getDays(
    String accessToken, String from, String to) async {
  var url = Uri.parse(
      'https://api.fitbit.com/1/user/-/activities/steps/date/$from/$to/15min.json');
  var response = await http.get(
    url,
    headers: {
      'authorization': 'Bearer $accessToken',
    },
  );
  if (response.statusCode == 429) {
    int secondsUntilReset =
        int.parse(response.headers['fitbit-rate-limit-reset']);
    throw new RatelimitExceeded(
        DateTime.now().subtract(Duration(seconds: secondsUntilReset)));
  }

  Map<String, dynamic> data = json.decode(response.body);
  List jsonlist = data['activities-steps'];
  List<FitbitDay> days = jsonlist.map((d) => FitbitDay.fromJson(d)).toList();

  return days;
}

Future<String> getAccessToken() async {
  final url = Uri.https('www.fitbit.com', '/oauth2/authorize', {
    'response_type': 'token',
    'client_id': '22BSFZ',
    'redirect_uri': '$API_URL/fitbit/callback',
    'scope': 'activity',
    'expires_in': '604800'
  });

  final result = await FlutterWebAuth.authenticate(
    url: url.toString(),
    callbackUrlScheme: 'wfhmovement',
  );
  final response = Uri.parse('?${Uri.parse(result).fragment}');
  final accessToken = response.queryParameters['access_token'];

  print(accessToken);
  return accessToken;
}

List<Map<String, dynamic>> transformSteps(List<FitbitStep> steps) {
  return steps
      .map((step) => {
            'value': step.value,
            'unit': 'COUNT',
            'date_from': step.dateTime.millisecondsSinceEpoch,
            'date_to': step.dateTime.millisecondsSinceEpoch,
            'data_type': 'STEPS',
            'platform_type': 'Fitbit',
          })
      .toList();
}
