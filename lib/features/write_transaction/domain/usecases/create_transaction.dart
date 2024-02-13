import 'package:cashflow/shared/data/models/wallet.dart';
import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/models/category.dart';
import '../../../../shared/data/models/transaction.dart';
import '../../../../shared/data/providers/isar.dart';

class _UseCase {
  final Isar _isar;

  _UseCase({required Isar isar}) : _isar = isar;

  FutureUseCase<int> call({
    required double amount,
    required String note,
    WalletModel? wallet,
    CategoryModel? category,
    required DateTime dateTime,
  }) async {
    try {
      if (wallet == null) {
        throw Failure(message: 'Tidak ada dompet dipilih!');
      }

      final currentDate = DateTime.now();
      final transaction = TransactionModel()
        ..amount = amount
        ..note = note
        ..wallet.value = wallet
        ..category.value = category
        ..date = dateTime
        ..createdAt = currentDate
        ..updatedAt = currentDate;

      if (category == null) {
        throw Failure(message: 'Tidak ada kategori dipilih!');
      }

      final result = await _isar.writeTxn(
        () async {
          final id = await _isar.transactionModels.put(transaction);
          await transaction.category.save();
          await transaction.wallet.save();
          return id;
        },
      );

      return Right(result);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(Failure(message: e.toString()));
    }
  }
}

// provider
final createTransactionUseCaseProvider = Provider<_UseCase>((ref) {
  return _UseCase(isar: ref.watch(isarProvider).instance);
});