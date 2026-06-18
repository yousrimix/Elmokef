import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../data/datasources/client_remote_datasource.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../domain/repositories/client_repository.dart';

final clientRemoteDataSourceProvider = Provider<ClientRemoteDataSource>((ref) {
  return ClientRemoteDataSource(ref.watch(apiClientProvider));
});

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepositoryImpl(
    remoteDataSource: ref.watch(clientRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// ── Submit Review ─────────────────────────────────────────────────
final submitReviewProvider = FutureProvider.family<Map<String, dynamic>, ({
  String clientId,
  String artisanId,
  String serviceId,
  int rating,
  String? comment,
})>((ref, params) async {
  final result = await ref.watch(clientRepositoryProvider).submitReview(
        clientId: params.clientId,
        artisanId: params.artisanId,
        serviceId: params.serviceId,
        rating: params.rating,
        comment: params.comment,
      );
  return result.fold((failure) => throw failure, (data) => data);
});

// ── Submit Complaint ──────────────────────────────────────────────
final submitComplaintProvider = FutureProvider.family<Map<String, dynamic>, ({
  String clientId,
  String artisanId,
  String reason,
  String? description,
  String? imageUrl,
})>((ref, params) async {
  final result = await ref.watch(clientRepositoryProvider).submitComplaint(
        clientId: params.clientId,
        artisanId: params.artisanId,
        reason: params.reason,
        description: params.description,
        imageUrl: params.imageUrl,
      );
  return result.fold((failure) => throw failure, (data) => data);
});

// ── Favorites ─────────────────────────────────────────────────────
final favoritesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.watch(clientRepositoryProvider).getFavorites();
  return result.fold((failure) => throw failure, (data) => data);
});
