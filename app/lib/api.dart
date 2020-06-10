import 'package:health/health.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// const API_URL = 'http://10.0.2.2:4000';
const API_URL = 'http://192.168.0.32:4000';

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
    DateTime _date = DateTime.parse('${json['key']}:00');
    date = _date.toIso8601String().substring(0, 10);
    hours = _date.hour;
    weekday = _date.weekday;
    value = json['value'].toDouble();
  }

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(json);
  }
}

Future<UserResponse> register(DateTime compareDate, String division) async {
  const url = '$API_URL/register';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'compareDate': DateTime.now().toIso8601String(),
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

Future<List<HealthData>> getSteps(
    String userId, DateTime from, DateTime to) async {
  var url =
      '$API_URL/$userId/hours?from=${from.toIso8601String()}&to=${to.toIso8601String()}';
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
