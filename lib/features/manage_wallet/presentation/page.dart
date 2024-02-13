import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/failure/failure.dart';
import '../../../core/router/router.gr.dart';
import '../../../shared/presentation/providers/wallets.dart';
import '../../../shared/presentation/widgets/empty_container.dart';
import '../../../shared/presentation/widgets/failure_container.dart';
import '../../../shared/presentation/widgets/loading_container.dart';

@RoutePage()
class ManageWalletPage extends HookConsumerWidget {
  const ManageWalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('build: manage wallet');

    return Scaffold(
      appBar: AppBar(title: const Text('Dompet')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.router.push(WriteWalletRoute()),
        child: const Icon(Icons.add_rounded),
      ),
      body: ref.watch(walletsProvider).maybeWhen(
            loading: () => const LoadingContainer(),
            error: (error, stackTrace) => FailureContainer(
              message: error is Failure ? error.message : error.toString(),
            ),
            data: (data) => data.isEmpty
                ? const EmptyContainer()
                : ListView.builder(
                    itemBuilder: (context, index) {
                      final wallet = data[index];

                      return ListTile(
                        title: Text(wallet.name),
                        trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert_rounded),
                        ),
                      );
                    },
                    itemCount: data.length,
                  ),
            orElse: () => const EmptyContainer(),
          ),
    );
  }
}
