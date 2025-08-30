import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/progress_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'آمار یادگیری',
          style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'پیشرفت در سطوح',
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: levels.asMap().entries.map((entry) {
                    final index = entry.key;
                    final level = entry.value;
                    final progressAsync = ref.watch(
                      progressNotifierProvider(level),
                    );
                    return progressAsync.when(
                      data: (progress) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: progress.retentionPercentage,
                            color: Colors.blue.shade400,
                            width: 15,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                      loading: () => BarChartGroupData(
                        x: index,
                        barRods: [BarChartRodData(toY: 0)],
                      ),
                      error: (error, _) => BarChartGroupData(
                        x: index,
                        barRods: [BarChartRodData(toY: 0)],
                      ),
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          levels[value.toInt()],
                          style: const TextStyle(fontFamily: 'Vazir'),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontFamily: 'Vazir'),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'جزئیات',
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  final progressAsync = ref.watch(
                    progressNotifierProvider(level),
                  );
                  return progressAsync.when(
                    data: (progress) => ListTile(
                      title: Text(
                        'سطح $level',
                        style: const TextStyle(fontFamily: 'Vazir'),
                      ),
                      subtitle: Text(
                        'لغات آموخته: ${progress.learnedCount}/${progress.totalCount}\n'
                        'درصد حفظ: ${progress.retentionPercentage.toStringAsFixed(1)}%\n'
                        'روزهای متوالی: ${progress.streak}',
                        style: const TextStyle(fontFamily: 'Vazir'),
                      ),
                    ),
                    loading: () =>
                        const ListTile(title: CircularProgressIndicator()),
                    error: (error, _) => ListTile(
                      title: Text(
                        'خطا: $error',
                        style: const TextStyle(fontFamily: 'Vazir'),
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final progressText = levels
                      .map((level) {
                        final progressAsync = ref.read(
                          progressNotifierProvider(level),
                        );
                        return progressAsync.when(
                          data: (progress) =>
                              'سطح $level: ${progress.retentionPercentage.toStringAsFixed(1)}% کامل شده',
                          loading: () => 'سطح $level: در حال بارگذاری',
                          error: (error, _) => 'سطح $level: خطا',
                        );
                      })
                      .join('\n');
                  await Share.share(
                    'پیشرفت من در یادگیری لغات:\n$progressText',
                  );
                },
                child: const Text(
                  'اشتراک‌گذاری پیشرفت',
                  style: TextStyle(fontFamily: 'Vazir'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
