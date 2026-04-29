import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ethio_liner/features/auth/data/auth_repository.dart';
import 'package:ethio_liner/features/auth/domain/models/user_model.dart';
import 'package:ethio_liner/features/auth/presentation/providers/auth_provider.dart';

class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  Future<AuthToken> login({required String email, required String password}) async {
    _currentUser = User(
      id: 1,
      email: email,
      fullName: 'Abebe Bikila',
      phoneNumber: '+251911223344',
      role: UserRole.passenger,
    );
    return const AuthToken(accessToken: 'mock_token');
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    _currentUser = User(
      id: 2,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: UserRole.passenger,
    );
    return _currentUser!;
  }

  @override
  Future<User> getCurrentUser() async {
    return _currentUser ??
        const User(
          id: 1,
          email: 'passenger@ethioliner.com',
          fullName: 'Abebe Bikila',
          phoneNumber: '+251911223344',
          role: UserRole.passenger,
        );
  }
}

void main() {
  group('Phase 4 - User & Auth Domain Models', () {
    test('User serialization and role conversion works correctly', () {
      const user = User(
        id: 42,
        email: 'passenger@ethioliner.com',
        fullName: 'Abebe Bikila',
        phoneNumber: '+251911223344',
        role: UserRole.passenger,
      );

      final json = user.toJson();
      expect(json['id'], equals(42));
      expect(json['role'], equals('PASSENGER'));

      final restored = User.fromJson(json);
      expect(restored.id, equals(user.id));
      expect(restored.email, equals(user.email));
      expect(restored.role, equals(UserRole.passenger));
    });

    test('UserRole display names are formatted for Ethiopian users', () {
      expect(UserRole.passenger.displayName, equals('Passenger'));
      expect(UserRole.operator.displayName, equals('Bus Operator'));
      expect(UserRole.admin.displayName, equals('Platform Administrator'));
    });
  });

  group('Phase 4 - AuthNotifier State Management', () {
    test('Login updates AuthState to authenticated', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      expect(container.read(authProvider).isAuthenticated, isFalse);

      final success = await notifier.login('passenger@ethioliner.com', 'password123');
      expect(success, isTrue);

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.user, isNotNull);
      expect(state.user!.email, equals('passenger@ethioliner.com'));

      // Logout
      notifier.logout();
      expect(container.read(authProvider).isAuthenticated, isFalse);
    });

    test('Register creates user and signs in', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      final success = await notifier.register(
        email: 'newuser@ethioliner.com',
        password: 'password123',
        fullName: 'Derartu Tulu',
        phoneNumber: '+251922334455',
      );

      expect(success, isTrue);
      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.user!.fullName, equals('Derartu Tulu'));
    });
  });
}
