import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class GlobalAnalytics {
  FirebaseAnalyticsObserver observer;

  init(FirebaseAnalytics firebaseAnalytics) {
    observer = FirebaseAnalyticsObserver(analytics: firebaseAnalytics);
  }

  static final GlobalAnalytics _analytics = GlobalAnalytics._internal();
  factory GlobalAnalytics() {
    return _analytics;
  }
  GlobalAnalytics._internal();
}

GlobalAnalytics globalAnalytics = GlobalAnalytics();
