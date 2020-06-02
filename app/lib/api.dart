import 'package:health/health.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

class User {
  String id;

  User(Map<String, dynamic> json) {
    id = json['id'];
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(json);
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
  int key;
  double value;

  HealthData(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'].toDouble();
  }

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(json);
  }
}

Future<String> register() async {
  const url = '$API_URL/register';
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  User user = User.fromJson(json.decode(response.body));

  return user.id;
}

Future<List<HealthData>> getSteps(
    String userId, DateTime from, DateTime to) async {
  var url =
      '$API_URL/$userId/weeks?from=${from.toIso8601String()}&to=${to.toIso8601String()}';
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
