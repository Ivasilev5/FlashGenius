import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keys for JWT tokens in secure storage.
class SecureStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
}

/// Secure storage for JWT tokens (Android Keystore / iOS Keychain).
class SecureStorage {
  SecureStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  final FlutterSecureStorage _storage;

  Future<void> writeAccessToken(String token) =>
      _storage.write(key: SecureStorageKeys.accessToken, value: token);

  Future<String?> readAccessToken() =>
      _storage.read(key: SecureStorageKeys.accessToken);

  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: SecureStorageKeys.refreshToken, value: token);

  Future<String?> readRefreshToken() =>
      _storage.read(key: SecureStorageKeys.refreshToken);

  Future<void> writeTokens({required String access, required String refresh}) async {
    await writeAccessToken(access);
    await writeRefreshToken(refresh);
  }

  Future<void> clearAll() => _storage.deleteAll();

  Future<bool> hasTokens() async {
    final access = await readAccessToken();
    return access != null && access.isNotEmpty;
  }
}
