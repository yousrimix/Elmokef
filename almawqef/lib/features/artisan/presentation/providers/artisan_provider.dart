import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/artisan_remote_datasource.dart';
import '../../data/repositories/artisan_repository_impl.dart';
import '../../domain/repositories/artisan_repository.dart';

final artisanRemoteDataSourceProvider = Provider<ArtisanRemoteDataSource>((ref) {
  return ArtisanRemoteDataSource(ref.watch(apiClientProvider));
});

final artisanRepositoryProvider = Provider<ArtisanRepository>((ref) {
  return ArtisanRepositoryImpl(
    remoteDataSource: ref.watch(artisanRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Get the current user's ID from auth state for artisan endpoints
final _artisanIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.id;
});

// ── Dashboard Stats ───────────────────────────────────────────────
final artisanStatsProvider = FutureProvider<ArtisanStats>((ref) async {
  final artisanId = ref.watch(_artisanIdProvider);
  if (artisanId == null) throw Exception('يجب تسجيل الدخول أولاً');
  final result = await ref.watch(artisanRepositoryProvider).getStats(artisanId);
  return result.fold((failure) => throw failure, (stats) => stats);
});

// ── Artisan Requests ──────────────────────────────────────────────
final artisanRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final artisanId = ref.watch(_artisanIdProvider);
  if (artisanId == null) throw Exception('يجب تسجيل الدخول أولاً');
  final result = await ref.watch(artisanRepositoryProvider).getRequests(artisanId);
  return result.fold((failure) => throw failure, (requests) => requests);
});

// ── Subscription Plans ────────────────────────────────────────────
final subscriptionPlansProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.watch(artisanRepositoryProvider).getPlans();
  return result.fold((failure) => throw failure, (plans) => plans);
});

// ── My Subscription ───────────────────────────────────────────────
final mySubscriptionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ref.watch(artisanRepositoryProvider).getMySubscription();
  return result.fold((failure) => throw failure, (sub) => sub);
});

// ── My Portfolio ──────────────────────────────────────────────────
final myPortfolioProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final artisanId = ref.watch(_artisanIdProvider);
  if (artisanId == null) throw Exception('يجب تسجيل الدخول أولاً');
  final result = await ref.watch(artisanRepositoryProvider).getMyPortfolio(artisanId);
  return result.fold((failure) => throw failure, (portfolio) => portfolio);
});

// ── Subscribe ─────────────────────────────────────────────────────
final subscribeProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, plan) async {
  final result = await ref.watch(artisanRepositoryProvider).subscribe(plan);
  return result.fold((failure) => throw failure, (data) => data);
});

// ── Cancel Subscription ───────────────────────────────────────────
final cancelSubscriptionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ref.watch(artisanRepositoryProvider).cancelSubscription();
  return result.fold((failure) => throw failure, (data) => data);
});

// ── Upgrade Subscription ──────────────────────────────────────────
final upgradeSubscriptionProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, plan) async {
  final result = await ref.watch(artisanRepositoryProvider).upgradeSubscription(plan);
  return result.fold((failure) => throw failure, (data) => data);
});
