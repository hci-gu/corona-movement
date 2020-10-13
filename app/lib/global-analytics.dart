import 'package:wfhmovement/api.dart' as api;

class GlobalAnalytics {
  String userId;

  init(String id) {
    userId = id;
    sendEvent('openApp');
  }

  sendEvent(String event, [Map<String, dynamic> parameters]) {
    api.sendAnalyticsEvent(event, parameters, userId);
  }

  static final GlobalAnalytics _analytics = GlobalAnalytics._internal();
  factory GlobalAnalytics() {
    return _analytics;
  }
  GlobalAnalytics._internal();
}

GlobalAnalytics globalAnalytics = GlobalAnalytics();
