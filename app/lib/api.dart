import 'package:health/health.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timezone/standalone.dart' as tz;
import 'package:intl/intl.dart';

// const API_URL = 'http://10.0.2.2:4000';
// const API_URL = 'http://192.168.0.32:4000';
const API_URL = 'https://api.mycoronamovement.com';

Future postData(String userId, List<HealthDataPoint> healthData) async {
  var url = '$API_URL/health-data';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'id': userId,
      'dataPoints': healthData.map((point) => point.toJson()).toList(),
    }),
  );
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  return response.body;
}

class UserResponse {
  String id;
  DateTime compareDate;
  String division;

  UserResponse(Map<String, dynamic> json) {
    id = json['_id'];
    compareDate = DateTime.parse(json['compareDate']);
    division = json['division'];
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
    date = DateTime.parse(json['date']);
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

Future<UserResponse> register(
    DateTime compareDate, DateTime initialDataDate, String division) async {
  const url = '$API_URL/register';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'compareDate': compareDate.toIso8601String().substring(0, 10),
      'initialDataDate': initialDataDate.toIso8601String().substring(0, 10),
      'division': division,
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
    },
  );

  return UserResponse.fromJson(json.decode(response.body));
}

Future updateUserCompareDate(String userId, DateTime compareDate) async {
  var url = '$API_URL/user/$userId';
  await http.patch(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'compareDate': compareDate.toIso8601String().substring(0, 10),
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
    },
  );
  ChartResult chart = ChartResult.fromJson(json.decode(response.body));

  List<HealthData> steps =
      chart.result.map((d) => HealthData.fromJson(d)).toList();

  return steps;
}

Future<HealthComparison> getComparison(String userId) async {
  var url = '$API_URL/$userId/summary';
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
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
    },
  );
  Map<String, dynamic> data = json.decode(response.body);

  return LatestUpload.fromJson(data);
}

Future<bool> unlock(String code) async {
  const url = '$API_URL/unlock';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'code': code,
    }),
  );

  return response.statusCode == 200;
}

Future<bool> ping() async {
  print('pingpong');
  const url = '$API_URL/ping';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
      {'date': DateTime.now().toIso8601String()},
    ),
  );

  return response.statusCode == 200;
}
