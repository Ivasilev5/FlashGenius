import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

/// Creates and configures Dio with base URL, interceptors (auth, logging).
Dio createDioClient(SecureStorage secureStorage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(dio, secureStorage),
    LogInterceptor(requestBody: true, responseBody: true),
  ]);

  return dio;
}

/// Adds Bearer token to requests; on 401 tries refresh and retries once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio, this._secureStorage);

  final Dio _dio;
  final SecureStorage _secureStorage;

  bool _isRefreshing = false;
  final List<_PendingRequest> _pending = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final options = err.requestOptions;
    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _secureStorage.clearAll();
      return handler.next(_authError(err));
    }

    if (_isRefreshing) {
      final completer = Completer<void>();
      _pending.add(_PendingRequest(options, completer, handler));
      await completer.future;
      return;
    }

    _isRefreshing = true;
    _pending.add(_PendingRequest(options, Completer<void>(), handler));

    try {
      final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await refreshDio.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
          contentType: 'application/json',
        ),
      );
      final data = response.data;
      final access = data?['data']?['access_token'] as String?;
      final newRefresh = data?['data']?['refresh_token'] as String?;
      if (access != null && newRefresh != null) {
        await _secureStorage.writeTokens(access: access, refresh: newRefresh);
        for (final p in _pending) {
          p.completer.complete();
          _retryRequest(p.options, p.handler, access);
        }
        _pending.clear();
      } else {
        await _secureStorage.clearAll();
        for (final p in _pending) {
          p.completer.complete();
          p.handler.next(_authError(err));
        }
        _pending.clear();
      }
    } catch (_) {
      await _secureStorage.clearAll();
      for (final p in _pending) {
        p.completer.complete();
        p.handler.next(_authError(err));
      }
      _pending.clear();
    } finally {
      _isRefreshing = false;
    }
  }

  void _retryRequest(RequestOptions options, ErrorInterceptorHandler handler, String accessToken) {
    options.headers['Authorization'] = 'Bearer $accessToken';
    _dio.fetch(options).then(
      (r) => handler.resolve(r),
      onError: (e) => handler.next(e is DioException ? e : DioException(requestOptions: options, error: e)),
    );
  }

  DioException _authError(DioException err) {
    return DioException(
      requestOptions: err.requestOptions,
      error: ApiException(
        message: 'Session expired',
        statusCode: 401,
        serverError: err.response?.data is Map
            ? (err.response!.data as Map)['error'] as String?
            : null,
      ),
    );
  }
}

class _PendingRequest {
  _PendingRequest(this.options, this.completer, this.handler);
  final RequestOptions options;
  final Completer<void> completer;
  final ErrorInterceptorHandler handler;
}
