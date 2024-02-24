import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../data/sources/isar.dart';
import '../../../../shared/data/models/transaction.dart';
import '../../../../shared/data/models/wallet.dart';
import '../../../../shared/presentation/providers/selected_wallet.dart';

class RecentTransactionsNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() async {
    final walletId = ref.watch(selectedWalletProvider).value?.id;
    if (walletId != null) {
      final currentDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
      );
      final nextDate = DateTime(
        currentDate.year,
        currentDate.month + 1,
      );

      _listenStream(
        walletId: walletId,
        currentDate: currentDate,
        nextDate: nextDate,
      );

      return _read(
        walletId: walletId,
        currentDate: currentDate,
        nextDate: nextDate,
      );
    }

    return [];
  }

  Future<List<TransactionModel>> _read({
    required int walletId,
    required DateTime currentDate,
    required DateTime nextDate,
  }) async {
    return await ref
        .watch(isarSourceProvider)
        .instance
        .transactionModels
        .filter()
        .wallet((q) => q.idEqualTo(walletId))
        .dateBetween(
          currentDate,
          nextDate,
          includeLower: true,
          includeUpper: false,
        )
        .sortByDateDesc()
        .limit(5)
        .findAll();
  }

  void _listenStream({
    required int walletId,
    required DateTime currentDate,
    required DateTime nextDate,
  }) {
    StreamSubscription subscription = ref
        .watch(isarSourceProvider)
        .instance
        .transactionModels
        .filter()
        .wallet((q) => q.idEqualTo(walletId))
        .dateBetween(
          currentDate,
          nextDate,
          includeLower: true,
          includeUpper: false,
        )
        .sortByDateDesc()
        .limit(5)
        .watchLazy()
        .listen((event) async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(
        () => _read(
          walletId: walletId,
          currentDate: currentDate,
          nextDate: nextDate,
        ),
      );
    });

    ref.onDispose(() => subscription.cancel());
  }
}

final recentTransactionsDataProvider =
    AsyncNotifierProvider<RecentTransactionsNotifier, List<TransactionModel>>(
  RecentTransactionsNotifier.new,
);
