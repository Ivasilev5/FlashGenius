import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage.dart';
import 'models/auth_response.dart';
import 'models/login_request.dart';
import 'models/register_request.dart';

class AuthRepository {
  AuthRepository(this._dio, this._storage);

  final Dio _dio;
  final SecureStorage _storage;

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: request.toJson(),
      );
      return _parseAuthResponse(response);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: request.toJson(),
      );
      return _parseAuthResponse(response);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (_) {
      // still clear local tokens
    }
    await _storage.clearAll();
  }

  AuthResponse _parseAuthResponse(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (data == null) throw ApiException(message: 'Empty response');
    final inner = data['data'];
    if (inner == null || inner is! Map<String, dynamic>) {
      throw ApiException(
        message: (data['error'] as String?) ?? 'Invalid response',
      );
    }
    return AuthResponse.fromJson(inner);
  }

  ApiException _toApiException(DioException e) {
    final data = e.response?.data;
    final errorMsg = data is Map ? data['error'] as String? : null;
    return ApiException(
      message: errorMsg ?? e.message ?? 'Network error',
      statusCode: e.response?.statusCode,
      serverError: errorMsg,
    );
  }
}
