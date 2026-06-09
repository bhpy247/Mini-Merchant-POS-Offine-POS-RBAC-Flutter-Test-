import 'package:minipostest/core/constants/parsing_helper.dart';

class UserModel {
  final String username;
  final String role;
  final String token;

  UserModel({required this.username, required this.role, required this.token});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: ParsingHelper.parseStringMethod(json['username']),
      role: ParsingHelper.parseStringMethod(json['role']),
      token: ParsingHelper.parseStringMethod(json['token']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'role': role, 'token': token};
  }

  UserModel copyWith({
    String? username,
    String? role,
    String? token
  }) {
    return UserModel(
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
