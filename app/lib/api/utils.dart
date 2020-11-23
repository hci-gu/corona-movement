class GlobalApiHandler {
  String timezone;

  init(String deviceLocalTimeZone) {
    timezone = deviceLocalTimeZone;
  }

  static final GlobalApiHandler _analytics = GlobalApiHandler._internal();
  factory GlobalApiHandler() {
    return _analytics;
  }
  GlobalApiHandler._internal();
}

GlobalApiHandler globalApiHandler = GlobalApiHandler();
