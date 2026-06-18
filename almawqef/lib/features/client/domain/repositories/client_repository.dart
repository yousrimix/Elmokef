import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ClientRepository {
  /// POST /reviews — submit a review
  Future<Either<Failure, Map<String, dynamic>>> submitReview({
    required String clientId,
    required String artisanId,
    required String serviceId,
    required int rating,
    String? comment,
  });

  /// POST /complaints — submit a complaint
  Future<Either<Failure, Map<String, dynamic>>> submitComplaint({
    required String clientId,
    required String artisanId,
    required String reason,
    String? description,
    String? imageUrl,
  });

  /// GET /favorites — get favorites list
  Future<Either<Failure, List<Map<String, dynamic>>>> getFavorites();
}
