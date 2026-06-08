import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_endpoints.dart';

// ─── Secure Storage Provider ──────────────────────────────────────────────────

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// ─── Base URL — auto detect platform ─────────────────────────────────────────

String get _baseUrl {
  if (kIsWeb) {
    return 'http://localhost:5000';
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://192.168.0.104:5000';        // PC hotspot IP
  }
  return 'http://localhost:5000';
}

// ─── Dio Provider ─────────────────────────────────────────────────────────────

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl:        _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // ── 1. Auth Token Interceptor ────────────────────────────────
  // Automatically attaches JWT to every request
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, handler) async {
        // ── 2. Auto token refresh on 401 ──────────────────────
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken(storage, dio);
          if (refreshed) {
            // Retry the original request with new token
            final token = await storage.read(key: 'auth_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
        }
        handler.next(error);
      },
    ),
  );

  // ── 3. Logging Interceptor (dev only) ────────────────────────
  assert(() {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
    );
    return true;
  }());

  return dio;
});

// ─── Token Refresh Helper ─────────────────────────────────────────────────────

Future<bool> _refreshToken(FlutterSecureStorage storage, Dio dio) async {
  try {
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    final response = await dio.post(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final newToken = response.data['access_token'];
    if (newToken != null) {
      await storage.write(key: 'auth_token', value: newToken);
      return true;
    }
    return false;
  } catch (_) {
    // Refresh failed — user needs to log in again
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'refresh_token');
    return false;
  }
}