/// Placeholder API client.
///
/// This will be fully implemented in Phase 12 when the Flutter
/// app connects to the FastAPI backend. For now, it provides
/// the interface that repositories will depend on.
///
/// The actual implementation will use the `http` or `dio` package
/// with authentication interceptors, error mapping, and timeout handling.
class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;

  // TODO(phase-12): Implement HTTP methods with auth interceptor
  // Future<Map<String, dynamic>> get(String path);
  // Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body});
  // Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body});
  // Future<Map<String, dynamic>> delete(String path);
}
