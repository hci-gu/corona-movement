import 'dart:io';
import 'dart:typed_data';

import 'package:health/health.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timezone/standalone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:wfhmovement/models/form_model.dart';

// const API_URL = 'http://10.0.2.2:4000';
const API_URL = 'http://192.168.0.32:4000';
const API_KEY = 'some-key';
// const API_URL = 'https://api.mycoronamovement.com';

Future postData(String userId, List<HealthDataPoint> healthData,
    bool createAggregation) async {
  var url = '$API_URL/health-data';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
    body: jsonEncode({
      'id': userId,
      'dataPoints': healthData.map((point) => point.toJson()).toList(),
      'createAggregation': createAggregation,
    }),
  );
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  return response.body;
}

class UserResponse {
  String id;
  DateTime compareDate;
  DateTime initialDataDate;
  double stepsEstimate;

  UserResponse(Map<String, dynamic> json) {
    id = json['_id'];
    compareDate = DateTime.parse(json['compareDate']);
    if (json['initialDataDate'] != null) {
      initialDataDate = DateTime.parse(json['initialDataDate']);
    }
    if (json['stepsEstimate'] != null) {
      stepsEstimate = json['stepsEstimate'];
    }
  }

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(json);
  }
}

class ChartResult {
  String from;
  String to;

  List<dynamic> result;

  ChartResult(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];

    result = json['result'];
  }

  factory ChartResult.fromJson(Map<String, dynamic> json) {
    return ChartResult(json);
  }
}

class HealthData {
  String date;
  int hours;
  int weekday;
  double value;

  HealthData(Map<String, dynamic> json) {
    var sthlm = tz.getLocation('Europe/Stockholm');
    var _date = tz.TZDateTime.parse(sthlm, '${json['key']}:00');
    date = DateFormat('yyyy-MM-dd')
        .format(_date); // _date.toIso8601String().substring(0, 10);
    hours = _date.hour;
    weekday = _date.weekday;
    value = json['value'].toDouble();
  }

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(json);
  }
}

class HealthComparison {
  HealthSummary user;
  HealthSummary others;

  HealthComparison(Map<String, dynamic> json) {
    user = HealthSummary.fromJson(json['user']);
    others = HealthSummary.fromJson(json['others']);
  }

  factory HealthComparison.fromJson(Map<String, dynamic> json) {
    return HealthComparison(json);
  }
}

class LatestUpload {
  DateTime date;
  String dataSource;

  LatestUpload(Map<String, dynamic> json) {
    var sthlm = tz.getLocation('Europe/Stockholm');
    date = tz.TZDateTime.parse(sthlm, '${json['date']}');
    dataSource = json['platform_type'];
  }

  factory LatestUpload.fromJson(Map<String, dynamic> json) {
    return LatestUpload(json);
  }
}

class HealthSummary {
  double before;
  double after;

  HealthSummary(Map<String, dynamic> json) {
    if (json['before'] != null)
      before = json['before'].toDouble();
    else
      before = 0.0;
    if (json['after'] != null)
      after = json['after'].toDouble();
    else
      after = 0.0;
  }

  factory HealthSummary.fromJson(Map<String, dynamic> json) {
    return HealthSummary(json);
  }
}

Future<UserResponse> register(DateTime compareDate, DateTime initialDataDate,
    String dataSource, String code) async {
  const url = '$API_URL/register';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
    body: jsonEncode({
      'compareDate': compareDate.toIso8601String().substring(0, 10),
      'initialDataDate': initialDataDate.toIso8601String().substring(0, 10),
      'code': code,
      'os': Platform.operatingSystem,
      'dataSource': dataSource
    }),
  );

  return UserResponse.fromJson(json.decode(response.body));
}

Future<UserResponse> getUser(String userId) async {
  var url = '$API_URL/user/$userId';
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
  );

  if (response.body == null || response.body == '')
    return null;

  return UserResponse.fromJson(json.decode(response.body));
}

Future<bool> deleteUser(String userId) async {
  var url = '$API_URL/user/$userId';
  var response = await http.delete(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
  );

  return response.statusCode == 200;
}

Future updateUserCompareDate(String userId, DateTime compareDate) async {
  var url = '$API_URL/user/$userId';
  await http.patch(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
    body: jsonEncode({
      'compareDate': compareDate.toIso8601String().substring(0, 10),
    }),
  );
}

Future updateUserEstimate(String userId, double stepsEstimate) async {
  var url = '$API_URL/user/$userId';
  await http.patch(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
    body: jsonEncode({
      'stepsEstimate': stepsEstimate,
    }),
  );
}

Future setUserFormData(String userId, FormModel form) async {
  var url = '$API_URL/user/$userId';
  await http.patch(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
    body: jsonEncode({
      'country': form.country,
      'gender': form.gender,
      'ageRange': form.ageRange,
      'education': form.education,
      'profession': form.profession,
      'organisation': form.organisation,
    }),
  );
}

Future<List<HealthData>> getSteps(
    String userId, DateTime from, DateTime to) async {
  var url =
      '$API_URL/$userId/hours?from=${from.toIso8601String().substring(0, 10)}&to=${to.toIso8601String().substring(0, 10)}';
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
  );
  ChartResult chart = ChartResult.fromJson(json.decode(response.body));

  if (chart.result != null) {
    List<HealthData> steps =
        chart.result.map((d) => HealthData.fromJson(d)).toList();
    return steps;
  }
  return null;
}

Future<HealthComparison> getComparison(String userId) async {
  var url = '$API_URL/$userId/summary';
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
  );
  HealthComparison comparison =
      HealthComparison.fromJson(json.decode(response.body));

  return comparison;
}

Future<LatestUpload> getLatestUpload(String userId) async {
  var url = '$API_URL/$userId/last-upload';
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
  );
  Map<String, dynamic> data = json.decode(response.body);

  return LatestUpload.fromJson(data);
}

Future<bool> shouldUnlock() async {
  const url = '$API_URL/should-unlock';
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
  );

  bool locked = json.decode(response.body);

  return locked;
}

Future<bool> unlock(String code) async {
  const url = '$API_URL/unlock';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
    body: jsonEncode({
      'code': code,
    }),
  );

  return response.statusCode == 200;
}

Future<bool> feedback(String text, Uint8List screenshot) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  const url = '$API_URL/feedback';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
    body: jsonEncode({
      'text': text,
      'os': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'appVersion': packageInfo.version,
      'appBuild': packageInfo.buildNumber
    }),
  );
  var result = jsonDecode(response.body);

  await http.put(result['uploadImageUrl'], body: screenshot);

  return response.statusCode == 200;
}

Future sendAnalyticsEvent(String event,
    [Map<String, dynamic> parameters, String userId]) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  const url = '$API_URL/analytics';
  await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
    body: jsonEncode({
      'userId': userId,
      'event': event,
      'device': {
        'os': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'appVersion': packageInfo.version,
        'appBuild': packageInfo.buildNumber
      },
      'parameters': parameters
    }),
  );
}

Future<bool> ping() async {
  print('pingpong');
  const url = '$API_URL/ping';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
    body: jsonEncode(
      {'date': DateTime.now().toIso8601String()},
    ),
  );

  return response.statusCode == 200;
}
