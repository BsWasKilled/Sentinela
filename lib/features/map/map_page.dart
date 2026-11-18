import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../alerts/domain/alert_type.dart';
import '../dashboards/widgets/report_filters.dart';
import '../territory/state/territory_provider.dart';
import 'widgets/alerts_map.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, this.embedded = false});

  /// Dentro da aba: sem botão de voltar.
  final bool embedded;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String? _region;
  AlertType? _type;
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final all = context.watch<TerritoryProvider>().all;
    final alerts = all
        .where((a) => _type == null || a.type == _type)
        .where((a) => _region == null || (a.location?.contains(_region!) ?? false))
        .toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Mapa de alertas'),
        actions: [
          IconButton(
            tooltip: _showFilters ? 'Ocultar filtros' : 'Filtrar',
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ReportFilters(
                region: _region,
                type: _type,
                onRegionChanged: (v) => setState(() => _region = v),
                onTypeChanged: (v) => setState(() => _type = v),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                AlertsMap(alerts: alerts, interactive: true),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            alerts.isEmpty
                                ? 'Nenhum alerta com esse filtro'
                                : '${alerts.length} alertas · toque em um marcador para ver os detalhes',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          const PriorityLegend(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
