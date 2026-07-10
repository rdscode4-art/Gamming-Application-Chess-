import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import 'storage_service.dart';

/// Central HTTP client for all REST API calls.
/// Automatically attaches Bearer token.
/// Handles 401 → redirects to login.
class ApiService {
  static Map<String, String> get _headers {
    final token = StorageService.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Bypass-Tunnel-Reminder': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── GET ────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> get(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ── POST ───────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ── PUT ────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> put(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> delete(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ── Response Handler ────────────────────────────────────────────────────────
  static Map<String, dynamic>? _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    }

    if (response.statusCode == 401) {
      StorageService.clear();
      throw Exception('Unauthorized');
    }

    final msg = decoded['message'] ?? 'Something went wrong';
    throw Exception(msg);
  }

  static void _handleError(dynamic e) {
    if (e.toString().contains('TimeoutException')) {
      throw Exception('Request timed out. Try again.');
    }
    if (e.toString().startsWith('Exception: ')) {
      throw e;
    }
    throw Exception('Network error. Check your connection.');
  }
}
