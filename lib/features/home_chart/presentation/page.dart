import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/extensions.dart';
import '../../../shared/enums/transaction_range_filter.dart';
import '../../../shared/presentation/providers/selected_date_range_filter.dart';
import '../../../shared/presentation/widgets/empty_container.dart';
import '../../../shared/presentation/widgets/loading_container.dart';
import 'providers/chart_data.dart';
import 'providers/selected_date_range.dart';

@RoutePage()
class HomeChartPage extends HookConsumerWidget {
  const HomeChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('build: home chart page');

    // global state
    final selectedTransactionRangeFilter =
        ref.watch(selectedDateRangeFilterProvider);

    // local state
    final selectedBarChartIndex = useState(0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Row(
              children: [
                IconButton.outlined(
                  onPressed: () =>
                      ref.read(selectedDateRangeProvider.notifier).previous(),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        switch (selectedTransactionRangeFilter) {
                          DateRangeFilter.yearly => 'Tahunan',
                          DateRangeFilter.monthly => 'Bulanan',
                          DateRangeFilter.daily => 'Harian',
                        },
                        style: context.textTheme.titleMedium,
                      ),
                      Builder(builder: (context) {
                        String start = '', end = '';
                        final firstDate =
                            ref.read(firstSelectedDateRangeProvider);
                        final lastDate =
                            ref.read(lastSelectedDateRangeProvider);

                        switch (selectedTransactionRangeFilter) {
                          case DateRangeFilter.yearly:
                            start = DateFormat.y().format(firstDate);
                            end = DateFormat.y().format(lastDate);
                          case DateRangeFilter.monthly:
                            start = DateFormat.yMMM().format(firstDate);
                            end = DateFormat.yMMM().format(lastDate);
                          case DateRangeFilter.daily:
                            start = DateFormat.yMMMd().format(firstDate);
                            end = DateFormat.yMMMd().format(lastDate);
                        }

                        return Text(
                          '$start - $end',
                          style: context.textTheme.bodySmall,
                        );
                      }),
                    ],
                  ),
                ),
                IconButton.outlined(
                  onPressed: () =>
                      ref.read(selectedDateRangeProvider.notifier).next(),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
            ),
            child: AspectRatio(
              aspectRatio: 12 / 7,
              child: ref.watch(chartDataProvider).maybeWhen(
                    loading: () => const LoadingContainer(),
                    data: (r) => BarChart(
                      BarChartData(
                        barTouchData: BarTouchData(
                          enabled: true,
                          handleBuiltInTouches: false,
                          touchCallback: (_, response) {
                            final groupIndex =
                                response?.spot?.touchedBarGroupIndex;
                            if (groupIndex != null) {
                              selectedBarChartIndex.value = groupIndex;
                            }
                          },
                        ),
                        gridData: const FlGridData(
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          leftTitles: const AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Text(
                                switch (selectedTransactionRangeFilter) {
                                  DateRangeFilter.daily => DateFormat.E()
                                      .format(r[value.toInt()].dateTime),
                                  DateRangeFilter.monthly => DateFormat.MMM()
                                      .format(r[value.toInt()].dateTime),
                                  DateRangeFilter.yearly => DateFormat.y()
                                      .format(r[value.toInt()].dateTime),
                                }
                                    .toLowerCase(),
                                style: context.textTheme.bodySmall,
                              ),
                            ),
                          ),
                        ),
                        barGroups: List.generate(
                          r.length,
                          (index) {
                            final chartData = r[index];
                            final isSelected =
                                index == selectedBarChartIndex.value;

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: chartData.totalIncome,
                                  width: 16,
                                  borderRadius: BorderRadius.circular(4),
                                  color: isSelected
                                      ? context.colorScheme.primary
                                          .withOpacity(.32)
                                      : context.colorScheme.primary,
                                  borderSide: BorderSide(
                                    color: isSelected
                                        ? context.colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                ),
                                BarChartRodData(
                                    toY: chartData.totalExpense,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                    color: isSelected
                                        ? context.colorScheme.primaryContainer
                                            .withOpacity(.32)
                                        : context.colorScheme.primaryContainer,
                                    borderSide: BorderSide(
                                      color: isSelected
                                          ? context.colorScheme.primaryContainer
                                          : Colors.transparent,
                                    )),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    orElse: () => const EmptyContainer(),
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 64,
              right: 64,
              top: 16,
            ),
            alignment: Alignment.center,
            child: Text(
              'Tekan salah satu bar chart untuk melihat rincian statistik',
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(8),

          // detail statistics
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.outlined(
                  onPressed: () {},
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Rincian statistik',
                      style: context.textTheme.titleMedium,
                    ),
                    Text(
                      DateFormat.yMMMMEEEEd().format(DateTime.now()),
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
                IconButton.outlined(
                  onPressed: () {},
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
            ),
            child: AspectRatio(
              aspectRatio: 12 / 7,
              child: PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 4,
                  sections: [
                    // income
                    PieChartSectionData(
                      value: 10,
                      color: context.colorScheme.primary,
                    ),

                    // expense
                    PieChartSectionData(
                      value: 20,
                      color: context.colorScheme.primaryContainer,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(16),

          // card income, expense
          Card(
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: Text(
                    'Status anggaran',
                    style: context.textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.trending_down_rounded),
                  ),
                  title: const Text('Defisit'),
                  subtitle: Text(NumberFormat.currency().format(-12000)),
                ),
                const Divider(),
                ListTile(
                  leading:
                      const CircleAvatar(child: Icon(Icons.south_west_rounded)),
                  title: const Text('Pemasukan'),
                  subtitle: Text(NumberFormat.currency().format(12000)),
                ),
                ListTile(
                  leading:
                      const CircleAvatar(child: Icon(Icons.north_east_rounded)),
                  title: const Text('Pengeluaran'),
                  subtitle: Text(NumberFormat.currency().format(12000)),
                ),
                const Gap(8),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 16,
              bottom: 8,
            ),
            child: Text(
              'Daftar transaksi',
              style: context.textTheme.titleMedium,
            ),
          ),

          // transactions
          ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                leading:
                    const CircleAvatar(child: Icon(Icons.south_west_rounded)),
                title: Text('Category name $index'),
                subtitle: const Text('Transaction note example'),
                trailing: Text(
                  NumberFormat.compactCurrency().format(12000),
                ),
                onTap: () {},
              );
            },
            itemCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),

          // spacer
          const Gap(56 + 32),
        ],
      ),
    );
  }
}
