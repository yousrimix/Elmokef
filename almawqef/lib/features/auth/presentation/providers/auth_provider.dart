import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ─── Data Sources ─────────────────────────────────────────────────
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});

// ─── Repository ───────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

// ─── Auth State ───────────────────────────────────────────────────
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final result = await _repository.isLoggedIn();
    final isLoggedIn = result.fold((_) => false, (value) => value);

    if (isLoggedIn) {
      final profileResult = await _repository.getProfile();
      profileResult.fold(
        (_) {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        },
        (user) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        },
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.login(
      email: email,
      phone: phone,
      password: password,
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (data) {
        final userJson = data['user'] as Map<String, dynamic>?;
        final user = userJson != null
            ? UserEntity(
                id: userJson['id'] as String,
                name: userJson['name'] as String,
                phone: userJson['phone'] as String,
                email: userJson['email'] as String?,
                role: userJson['role'] as String,
                image: userJson['image'] as String?,
              )
            : null;
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
      },
    );
  }

  Future<void> register({
    required String name,
    required String phone,
    String? email,
    required String password,
    bool isArtisan = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = isArtisan
        ? await _repository.registerArtisan(
            name: name,
            phone: phone,
            email: email,
            password: password,
          )
        : await _repository.register(
            name: name,
            phone: phone,
            email: email,
            password: password,
          );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (data) {
        final userJson = data['user'] as Map<String, dynamic>?;
        final user = userJson != null
            ? UserEntity(
                id: userJson['id'] as String,
                name: userJson['name'] as String,
                phone: userJson['phone'] as String,
                email: userJson['email'] as String?,
                role: userJson['role'] as String,
                image: userJson['image'] as String?,
              )
            : null;
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
      },
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshProfile() async {
    final result = await _repository.getProfile();
    result.fold(
      (_) {},
      (user) {
        state = state.copyWith(user: user);
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
