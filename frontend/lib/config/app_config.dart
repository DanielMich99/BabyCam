class AppConfig {
  //static const String baseUrl = 'http://192.168.1.224:8000';
  //static const String baseUrl = 'http://192.168.1.225:8000';
  static const String baseUrl = 'http://192.168.1.228:8000';

  // API Endpoints
  static const String detectionResultsEndpoint = '/detection_results';
  static const String babyProfilesEndpoint = '/baby_profiles';
  static const String monitoringEndpoint = '/monitoring';

  // Get full URL for an endpoint
  static String getUrl(String endpoint) => '$baseUrl$endpoint';
}
