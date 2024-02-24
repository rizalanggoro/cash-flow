import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../data/models/transaction.dart';
import '../../../../data/sources/isar.dart';

class _UseCase {
  final Isar _isar;

  _UseCase({required Isar isar}) : _isar = isar;

  FutureUseCase<bool> call({required int transactionId}) async {
    try {
      final result = await _isar.writeTxn(
        () => _isar.transactionModels.delete(transactionId),
      );

      return Right(result);
    } catch (e) {
      return Left(
        e is Failure ? e : Failure(message: e.toString()),
      );
    }
  }
}

// provider
final deleteTransactionUseCaseProvider = Provider<_UseCase>((ref) {
  return _UseCase(isar: ref.watch(isarSourceProvider).instance);
});
