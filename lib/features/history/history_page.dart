import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/widgets/state_message.dart';
import '../alerts/domain/alert_type.dart';
import '../alerts/presentation/widgets/alert_card.dart';
import '../dashboards/widgets/report_filters.dart';
import '../territory/state/territory_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? _region;
  AlertType? _type;

  @override
  Widget build(BuildContext context) {
    final all = context.watch<TerritoryProvider>().all;
    final items = all
        .where((a) => _type == null || a.type == _type)
        .where((a) => _region == null || (a.location?.contains(_region!) ?? false))
        .toList();
    final hasFilter = _region != null || _type != null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Histórico de alertas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ReportFilters(
              region: _region,
              type: _type,
              onRegionChanged: (v) => setState(() => _region = v),
              onTypeChanged: (v) => setState(() => _type = v),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: StateMessage(
                      icon: Icons.inbox_outlined,
                      title: hasFilter
                          ? 'Nenhum alerta com esse filtro'
                          : 'Nenhum alerta registrado',
                      message: hasFilter
                          ? 'Alertas gerados para todo o território aparecem só em "Todas as regiões".'
                          : 'Os alertas gerados e os relatos aparecem aqui.',
                      actionLabel: 'Limpar filtros',
                      onAction: hasFilter
                          ? () => setState(() {
                                _region = null;
                                _type = null;
                              })
                          : null,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => AlertCard(
                      alert: items[i],
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.alertDetail,
                        arguments: items[i],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
