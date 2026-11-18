import 'package:flutter/material.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/charts/stat_tile.dart';
import '../../territory/domain/indicator.dart';
import '../../territory/domain/territory_dataset.dart';
import '../../territory/domain/trend.dart';

/// Grade de cards de indicadores; cada um abre a tela de detalhe.
class IndicatorGrid extends StatelessWidget {
  const IndicatorGrid({
    super.key,
    required this.indicators,
    required this.data,
  });

  final List<Indicator> indicators;
  final TerritoryDataset data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.35,
          children: [
            for (final ind in indicators)
              Builder(builder: (context) {
                final series = ind.series(data.history);
                final current = series.isEmpty ? 0.0 : series.last;
                return StatTile(
                  label: ind.label,
                  value: ind.format(current),
                  unit: ind.unit,
                  icon: ind.icon,
                  trend: series.length >= 2 ? Trend.of(series) : null,
                  upIsBad: ind != Indicator.humidity,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.indicatorDetail,
                    arguments: ind,
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
