class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:8000';

  // API Endpoints
  static const String detectionResultsEndpoint = '/detection_results';
  static const String babyProfilesEndpoint = '/baby_profiles';

  // Get full URL for an endpoint
  static String getUrl(String endpoint) => '$baseUrl$endpoint';
}
