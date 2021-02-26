import 'dart:io';
import 'dart:typed_data';

import 'package:health/health.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:wfhmovement/api/responses.dart';
import 'package:wfhmovement/api/utils.dart';
import 'package:wfhmovement/models/form_model.dart';

// const API_URL = 'http://10.0.2.2:4000';
const API_URL = 'http://192.168.0.32:4000';
const API_KEY = 'some-key';
// const API_URL = 'https://api.mycoronamovement.com';

Future postJsonData(String userId, List<Map<String, dynamic>> data,
    bool createAggregation) async {
  var url = '$API_URL/health-data';
  var response = await http
      .post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'api-key': API_KEY,
        },
        body: jsonEncode({
          'id': userId,
          'dataPoints': data,
          'createAggregation': createAggregation,
          'timezone': globalApiHandler.timezone,
        }),
      )
      .timeout(Duration(seconds: 20));
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  return response.body;
}

Future postData(
    String userId, List<HealthDataPoint> healthData, bool createAggregation) {
  return postJsonData(
    userId,
    healthData.map((point) {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['value'] = point.value;
      data['unit'] = point.unit.toString();
      data['date_from'] = point.dateFrom.millisecondsSinceEpoch;
      data['date_to'] = point.dateTo.millisecondsSinceEpoch;
      data['data_type'] = point.type.toString();
      data['platform_type'] = point.platform.toString();
      return data;
    }).toList(),
    createAggregation,
  );
}

Future<UserResponse> register(
    List<DatePeriod> afterPeriods,
    DateTime initialDataDate,
    String dataSource,
    String code,
    bool workedFromHome) async {
  const url = '$API_URL/register';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
    body: jsonEncode({
      'afterPeriods': afterPeriods != null
          ? afterPeriods.map((e) => e.toJson()).toList()
          : null,
      'initialDataDate': initialDataDate.toIso8601String().substring(0, 10),
      'code': code,
      'os': Platform.operatingSystem,
      'dataSource': dataSource,
      'workedFromHome': workedFromHome,
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

  if (response.body == null || response.body == '') return null;

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

Future updateUserAfterPeriods(
    String userId, List<DatePeriod> afterPeriods) async {
  var url = '$API_URL/user/$userId';
  await http.patch(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
    body: jsonEncode({
      'afterPeriods': afterPeriods.map((e) => e.toJson()).toList(),
      'timezone': globalApiHandler.timezone,
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
      'occupation': form.occupation,
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

Future<AllUserData> getDataForAllUser() async {
  var url = '$API_URL/all';
  var response = await http.get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'api-key': API_KEY,
  });

  AllUserData data = AllUserData.fromJson(json.decode(response.body));
  return data;
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

Future<Group> getGroup(String groupId) async {
  var url = '$API_URL/groups/$groupId';
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
  );
  Group group = Group(json.decode(response.body));
  return group;
}

Future<Group> getAndjoinGroup(String groupCode, String userId) async {
  var url = '$API_URL/groups/code/$groupCode';
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
  );
  if (response.statusCode == 200) {
    Group group = Group(json.decode(response.body));
    await joinGroup(group.id, userId);

    return group;
  }

  return null;
}

Future<bool> joinGroup(String groupId, String userId) async {
  var url = '$API_URL/groups/$groupId/join';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
    body: json.encode({
      'userId': userId,
    }),
  );

  return response.statusCode == 200;
}

Future<bool> leaveGroup(String groupId, String userId) async {
  var url = '$API_URL/groups/$groupId/$userId';
  var response = await http.delete(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
    },
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

Future<List<DateEvent>> getEvents(String languageCode) async {
  var url = '$API_URL/events';
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'api-key': API_KEY,
      'language': languageCode,
    },
  );
  List data = json.decode(response.body);

  return data.map((e) => DateEvent.fromJson(e)).toList();
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
