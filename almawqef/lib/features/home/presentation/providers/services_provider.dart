import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../data/datasources/services_remote_datasource.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../../data/models/category_model.dart';
import '../../domain/repositories/services_repository.dart';

final servicesRemoteDataSourceProvider = Provider<ServicesRemoteDataSource>((ref) {
  return ServicesRemoteDataSource(ref.watch(apiClientProvider));
});

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepositoryImpl(
    ref.watch(servicesRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

// ── Categories (service tree) ─────────────────────────────────────
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final result = await ref.watch(servicesRepositoryProvider).getCategories();
  return result.fold(
    (failure) => throw failure,
    (categories) => categories,
  );
});

// ── Suggested artisans (home screen) ──────────────────────────────
final suggestedArtisansProvider = FutureProvider<List<ArtisanModel>>((ref) async {
  final result = await ref.watch(servicesRepositoryProvider).getSuggestedArtisans();
  return result.fold(
    (failure) => throw failure,
    (artisans) => artisans,
  );
});

// ── Search query state ────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');

// ── Artisans by service ───────────────────────────────────────────
final artisansProvider = FutureProvider.family<List<ArtisanModel>, String>((ref, serviceId) async {
  final result = await ref.watch(servicesRepositoryProvider).getArtisans(serviceId: serviceId);
  return result.fold(
    (failure) => throw failure,
    (artisans) => artisans,
  );
});

// ── Artisan profile ───────────────────────────────────────────────
final artisanProfileProvider = FutureProvider.family<ArtisanModel, String>((ref, id) async {
  final result = await ref.watch(servicesRepositoryProvider).getArtisanProfile(id);
  return result.fold(
    (failure) => throw failure,
    (artisan) => artisan,
  );
});

// ── Artisan reviews ───────────────────────────────────────────────
final artisanReviewsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, artisanId) async {
  final result = await ref.watch(servicesRepositoryProvider).getArtisanReviews(artisanId);
  return result.fold(
    (failure) => throw failure,
    (data) => data,
  );
});

// ── Artisan portfolio ─────────────────────────────────────────────
final artisanPortfolioProvider = FutureProvider.family<List<PortfolioModel>, String>((ref, artisanId) async {
  final result = await ref.watch(servicesRepositoryProvider).getArtisanPortfolio(artisanId);
  return result.fold(
    (failure) => throw failure,
    (portfolio) => portfolio,
  );
});

// ── Search services ───────────────────────────────────────────────
final searchServicesProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, query) async {
  final result = await ref.watch(servicesRepositoryProvider).searchServices(query: query);
  return result.fold(
    (failure) => throw failure,
    (data) => data,
  );
});

// ── Search artisans by text ───────────────────────────────────────
final textSearchProvider = FutureProvider.family<List<ArtisanModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final result = await ref.watch(servicesRepositoryProvider).searchArtisansByText(query.trim());
  return result.fold(
    (failure) => throw failure,
    (artisans) => artisans,
  );
});
