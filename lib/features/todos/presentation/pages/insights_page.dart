import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todolocal/core/design_tokens.dart';
import '../../application/analytics.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(analyticsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: Padding(
        padding: const EdgeInsets.all(Tkn.s6),
        child: ListView(
          children: [
            Text('Taux d’achèvement', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: const BorderRadius.all(Tkn.rXl),
              ),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('${(a.completionRate * 100).toStringAsFixed(0)} %',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: Tkn.s6),

            Text('Dernières 8 semaines', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (var i = 0; i < a.last8Weeks.length; i++)
                      BarChartGroupData(x: i, barsSpace: 4, barRods: [
                        BarChartRodData(toY: a.last8Weeks[i].created.toDouble(), width: 10),
                        BarChartRodData(toY: a.last8Weeks[i].completed.toDouble(), width: 10),
                      ]),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= a.last8Weeks.length) return const SizedBox.shrink();
                          final d = a.last8Weeks[i].weekStart;
                          return Text('${d.day}/${d.month}', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: Tkn.s6),
            Text('Top tags', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: a.topTags.isEmpty
                  ? [Text('Aucun tag pour l’instant', style: TextStyle(color: cs.onSurfaceVariant))]
                  : a.topTags.map((t) => Chip(label: Text('#${t.tag} (${t.count})'))).toList(),
            ),

            const SizedBox(height: Tkn.s6),
            Text('Répartition des priorités', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(value: (a.priorityDist[0]).toDouble(), title: 'Low'),
                    PieChartSectionData(value: (a.priorityDist[1]).toDouble(), title: 'Med'),
                    PieChartSectionData(value: (a.priorityDist[2]).toDouble(), title: 'High'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
