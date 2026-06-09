import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: "token", value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: "role", value: role);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: "role");
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  static Future<void> saveUsername(String username) async {
    await _storage.write(key: "username", value: username);
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: "username");
  }
}
