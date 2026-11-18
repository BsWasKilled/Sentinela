import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/home_shell.dart';
import '../territory/domain/indicator.dart';
import '../territory/state/territory_provider.dart';
import 'climate_dashboard_page.dart';
import 'resources_dashboard_page.dart';
import 'services_dashboard_page.dart';

/// Os três painéis territoriais em abas: Clima, Recursos e Serviços.
class DashboardsPage extends StatefulWidget {
  const DashboardsPage({super.key});

  @override
  State<DashboardsPage> createState() => _DashboardsPageState();
}

class _DashboardsPageState extends State<DashboardsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller =
      TabController(length: DashboardKind.values.length, vsync: this);
  ValueNotifier<int>? _requested;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = HomeShellScope.maybeOf(context);
    if (scope != null && _requested != scope.dashboardTab) {
      _requested?.removeListener(_onRequested);
      _requested = scope.dashboardTab..addListener(_onRequested);
    }
  }

  void _onRequested() {
    final i = _requested?.value;
    if (i != null && i != _controller.index) _controller.animateTo(i);
  }

  @override
  void dispose() {
    _requested?.removeListener(_onRequested);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final refreshing = context.select<TerritoryProvider, bool>((s) => s.isRefreshing);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Painéis'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(refreshing ? 51 : 48),
          child: Column(
            children: [
              TabBar(
                controller: _controller,
                tabs: [
                  for (final k in DashboardKind.values)
                    Tab(icon: Icon(k.icon, size: 20), text: k.label, height: 48),
                ],
              ),
              if (refreshing) const LinearProgressIndicator(minHeight: 3),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [
          ClimateDashboardPage(embedded: true),
          ResourcesDashboardPage(embedded: true),
          ServicesDashboardPage(embedded: true),
        ],
      ),
    );
  }
}
