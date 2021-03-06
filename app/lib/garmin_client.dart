import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class GarminException implements Exception {
  String message;
  GarminException(this.message);
  String toString() => "GarminException: $message";
}

class GarminStep {
  DateTime startGMT;
  DateTime endGMT;
  int steps;

  GarminStep(Map<String, dynamic> json) {
    startGMT = DateTime.parse(json['startGMT']);
    endGMT = DateTime.parse(json['endGMT']);
    steps = json['steps'];
  }

  factory GarminStep.fromJson(Map<String, dynamic> json) {
    return GarminStep(json);
  }
}

class GarminClient {
  String username;
  String password;
  String displayName;

  Dio dio;

  GarminClient(this.username, this.password);

  Future<void> connect() async {
    dio = Dio()..interceptors.add(CookieManager(CookieJar()));

    await _authenticate();
  }

  Future _authenticate() async {
    // Step 1: Post credentials
    Response authResponse = await dio.post('https://sso.garmin.com/sso/signin',
        queryParameters: {'service': 'https://connect.garmin.com/modern'},
        data: {'username': username, 'password': password, 'embed': 'false'},
        options:
            Options(contentType: 'application/x-www-form-urlencoded', headers: {
          'origin': 'https://sso.garmin.com',
        }));
    if (authResponse.statusCode != 200) {
      throw GarminException('Login credentials not accepted');
    }

    // Step 2: Extract auth ticket url from response
    RegExp exp = RegExp(r'response_url\s*=\s*"(https:[^"]+)"');
    RegExpMatch match = exp.firstMatch(authResponse.data);
    if (match == null) {
      throw GarminException(
          'No auth ticket URL found. Did you specify correct credentials?');
    }
    String url = match.group(1).replaceAll('\\', '');

    // Step 3: Visit ticket URL in order to grab session cookie
    // N.B. Code is complicated to allow for Garmin's weird auth flow
    // with multiple redirects eventually landing on the original URL.
    // Todo: open ticket on Dio repo arguing Redirect Loops should be possible.
    Response claimResponse;
    bool isRedirect = true;
    while (isRedirect) {
      claimResponse = await dio.get(url,
          options: Options(
              followRedirects: false,
              validateStatus: (status) {
                return status < 400; // Work-around to not throw error on 302s
              }));
      // Can't use response.isRedirect because 302s are deprecated and not marked as redirects
      if (claimResponse.statusCode == 302) {
        url = claimResponse.headers['location'][0];
      } else {
        isRedirect = false;
      }
    }
    if (claimResponse.statusCode != 200) {
      throw GarminException('Failed to get session through auth ticket URL');
    }

    // Step 4: Get user displayName
    await getDisplayName();
  }

  Future<void> getDisplayName() async {
    Response response = await dio
        .get('https://connect.garmin.com/modern/currentuser-service/user/info');
    displayName = response.data['displayName'];
  }

  Future<List<Map<String, dynamic>>> fetchSteps(String dateString) async {
    Response response = await dio.get(
      'https://connect.garmin.com/modern/proxy/wellness-service/wellness/dailySummaryChart/$displayName?date=$dateString',
      options: Options(
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36',
          'Referer': 'https://connect.garmin.com/modern/dashboard/',
          'origin': 'https://sso.garmin.com',
          'nk': 'NT',
        },
      ),
    );
    List<dynamic> data = response.data;
    List<GarminStep> steps = data.map((d) => GarminStep.fromJson(d)).toList();

    return transformSteps(steps);
  }

  List<Map<String, dynamic>> transformSteps(List<GarminStep> steps) {
    return steps
        .map((step) => {
              'value': step.steps,
              'unit': 'COUNT',
              'date_from': step.startGMT.millisecondsSinceEpoch,
              'date_to': step.endGMT.millisecondsSinceEpoch,
              'data_type': 'STEPS',
              'platform_type': 'Garmin',
            })
        .toList();
  }
}
