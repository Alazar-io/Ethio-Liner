import 'package:equatable/equatable.dart';

/// User roles supported across EthioLiner.
enum UserRole {
  passenger,
  operator,
  admin;

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'OPERATOR':
        return UserRole.operator;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.passenger;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.passenger:
        return 'Passenger';
      case UserRole.operator:
        return 'Bus Operator';
      case UserRole.admin:
        return 'Platform Administrator';
    }
  }
}

/// Representation of an authenticated user.
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.role = UserRole.passenger,
    this.isActive = true,
  });

  final int id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final UserRole role;
  final bool isActive;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 1,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'PASSENGER'),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role.name.toUpperCase(),
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [id, email, fullName, phoneNumber, role, isActive];
}

/// Authentication token response.
class AuthToken extends Equatable {
  const AuthToken({
    required this.accessToken,
    this.tokenType = 'bearer',
    this.expiresInMinutes = 1440,
  });

  final String accessToken;
  final String tokenType;
  final int expiresInMinutes;

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresInMinutes: json['expires_in_minutes'] as int? ?? 1440,
    );
  }

  @override
  List<Object?> get props => [accessToken, tokenType, expiresInMinutes];
}
