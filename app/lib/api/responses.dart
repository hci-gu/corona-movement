import 'package:timezone/standalone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:wfhmovement/api/utils.dart';

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
    String timezone = globalApiHandler.timezone ?? 'Europe/Stockholm';
    var _date =
        tz.TZDateTime.parse(tz.getLocation(timezone), '${json['key']}:00');
    date = DateFormat('yyyy-MM-dd').format(_date);
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

class Group {
  String id;
  String name;

  Group(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(json);
  }
}
