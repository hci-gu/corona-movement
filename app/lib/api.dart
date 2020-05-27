import 'package:health/health.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const API_URL = 'https://api.mycoronamovement.com';

Future postData(
    String userId, int offset, List<HealthDataPoint> healthData) async {
  var url = '$API_URL/health-data';
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'id': userId,
      'offset': offset,
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

class ChartData {
  List<Map<String, int>> data;

  ChartData(Map<String, dynamic> json) {
    data = json['result'];
  }

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(json);
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

Future<ChartData> getSteps(String userId, DateTime from, DateTime to) async {
  var url = '$API_URL/$userId/weeks';
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  ChartData steps = ChartData.fromJson(json.decode(response.body));

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
