class EnvironmentConfig {
  static const APP_NAME = String.fromEnvironment(
    'WFHMOVEMENT_APP_NAME',
    defaultValue: 'WFH Movement',
  );
  static const APP_SUFFIX = String.fromEnvironment('WFHMOVEMENT_APP_SUFFIX');
}
