import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../errors/app_exception.dart';

/// Robust API Client for EthioLiner.
///
/// Handles HTTP requests to the FastAPI backend, authentication bearer tokens,
/// JSON serialization, and error mapping to [AppException].
class ApiClient {
  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
  })  : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _client = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  /// Sets the JWT Bearer authorization token.
  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters);
      final response = await _client
          .get(uri, headers: _buildHeaders())
          .timeout(AppConfig.apiTimeout);
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(details: e.message);
    } on TimeoutException catch (e) {
      throw NetworkException(message: 'Request timed out. Please try again.', details: e.message);
    }
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await _client
          .post(uri, headers: _buildHeaders(), body: body != null ? jsonEncode(body) : null)
          .timeout(AppConfig.apiTimeout);
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(details: e.message);
    } on TimeoutException catch (e) {
      throw NetworkException(message: 'Request timed out. Please try again.', details: e.message);
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic jsonBody;
    try {
      if (response.body.isNotEmpty) {
        jsonBody = jsonDecode(response.body);
      }
    } catch (_) {
      jsonBody = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return jsonBody;
    } else if (statusCode == 401) {
      final detail = jsonBody is Map ? jsonBody['detail']?.toString() : null;
      throw AuthException(message: detail ?? 'Invalid credentials or expired session.');
    } else if (statusCode == 403) {
      final detail = jsonBody is Map ? jsonBody['detail']?.toString() : null;
      throw ForbiddenException(message: detail ?? 'Permission denied.');
    } else if (statusCode == 404) {
      final detail = jsonBody is Map ? jsonBody['detail']?.toString() : null;
      throw NotFoundException(message: detail ?? 'Resource not found.');
    } else if (statusCode == 400 || statusCode == 422) {
      final detail = jsonBody is Map ? jsonBody['detail']?.toString() : null;
      throw ValidationException(message: detail ?? 'Invalid request data.');
    } else if (statusCode >= 500) {
      throw ServerException(statusCode: statusCode);
    } else {
      throw AppException(message: 'Unexpected server response: $statusCode');
    }
  }
}
