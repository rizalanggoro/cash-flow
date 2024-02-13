import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/models/category.dart';
import '../../../../shared/data/models/wallet.dart';
import '../../../../shared/data/providers/isar.dart';
import '../../../../shared/enums/category_filter.dart';
import '../../../../shared/enums/category_type.dart';

class _UseCase {
  final Isar _isar;

  _UseCase({required Isar isar}) : _isar = isar;

  UseCase<Stream<void>> call({required CategoryFilter filter, int? walletId}) =>
      walletId == null
          ? Left(Failure(message: 'Tidak ada dompet yang dipilih!'))
          : Right(_isar.categoryModels
              .filter()
              .wallet((q) => q.idEqualTo(walletId))
              .optional(
                filter.isIncome,
                (q) => q.typeEqualTo(CategoryType.income),
              )
              .optional(
                filter.isExpense,
                (q) => q.typeEqualTo(CategoryType.expense),
              )
              .watchLazy());
}

// provider
final watchCategoriesUseCaseProvider = Provider<_UseCase>((ref) {
  return _UseCase(isar: ref.watch(isarProvider).instance);
});