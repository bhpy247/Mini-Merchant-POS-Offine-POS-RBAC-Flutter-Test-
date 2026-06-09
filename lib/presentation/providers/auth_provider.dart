import 'package:flutter/material.dart';
import 'package:minipostest/data/repsitory/auth_repo_impl.dart';

import '../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../domain/repository/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthProvider(this.repository);

  bool isLoading = false;

  UserModel? user;

  Future<bool> login({required String username, required String password}) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await repository.login(username: username, password: password);
      user = UserModel.fromJson(response.toJson());

      await StorageService.saveToken(user?.token ?? "");
      await StorageService.saveRole(user?.role ?? "ADMIN");
      await StorageService.saveUsername(user?.username ?? "");

      return true;
    } catch (e) {
      print("error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
