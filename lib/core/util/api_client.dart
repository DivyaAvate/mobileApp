import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final dioProvider = Provider<Dio>((ref) {
  // If running on Web (Chrome), use localhost. 
  // If running on Android Emulator, use 10.0.2.2.
  final String baseUrl = kIsWeb 
      ? 'http://localhost:5000/api' 
      : 'http://10.0.2.2:5000/api';

  return Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
});