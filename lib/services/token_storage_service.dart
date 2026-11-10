import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<String?> readToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  Future<String?> readSavedUsername();
  Future<void> saveUsername(String? username);
}

class SecureTokenStorage implements TokenStorage {
  static const String _tokenKey = 'scp_auth_token';
  static const String _usernameKey = 'scp_saved_username';

  final FlutterSecureStorage _storage;

  const SecureTokenStorage({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {}
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {}
  }

  @override
  Future<String?> readSavedUsername() async {
    try {
      return await _storage.read(key: _usernameKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUsername(String? username) async {
    try {
      if (username == null || username.isEmpty) {
        await _storage.delete(key: _usernameKey);
      } else {
        await _storage.write(key: _usernameKey, value: username);
      }
    } catch (_) {}
  }
}

class MemoryTokenStorage implements TokenStorage {
  String? _token;
  String? _username;

  MemoryTokenStorage({String? initialToken}) : _token = initialToken;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<void> deleteToken() async {
    _token = null;
  }

  @override
  Future<String?> readSavedUsername() async => _username;

  @override
  Future<void> saveUsername(String? username) async {
    _username = username;
  }
}

