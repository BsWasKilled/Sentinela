import 'package:flutter/material.dart';

import '../dashboards/dashboards_page.dart';
import '../history/history_page.dart';
import '../map/map_page.dart';
import 'home_page.dart';

/// Permite que as abas troquem entre si (ex.: "Ver histórico" no início).
class HomeShellScope extends InheritedWidget {
  const HomeShellScope({
    super.key,
    required this.goToTab,
    required this.dashboardTab,
    required super.child,
  });

  final void Function(int index) goToTab;

  /// Aba de painel pedida pela tela inicial (0 clima, 1 recursos, 2 serviços).
  final ValueNotifier<int> dashboardTab;

  static HomeShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeShellScope>();

  void goToDashboard(int tab) {
    dashboardTab.value = tab;
    goToTab(1);
  }

  @override
  bool updateShouldNotify(HomeShellScope oldWidget) => false;
}

/// Casca com barra inferior. As telas de detalhe abrem por rotas nomeadas
/// por cima desta casca.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _dashboardTab = ValueNotifier<int>(0);

  static const _tabs = [
    (icon: Icons.home_outlined, selected: Icons.home, label: 'Início'),
    (icon: Icons.insights_outlined, selected: Icons.insights, label: 'Painéis'),
    (icon: Icons.map_outlined, selected: Icons.map, label: 'Mapa'),
    (icon: Icons.history_outlined, selected: Icons.history, label: 'Histórico'),
  ];

  @override
  void dispose() {
    _dashboardTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomeShellScope(
      goToTab: (i) => setState(() => _index = i),
      dashboardTab: _dashboardTab,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [
            HomePage(),
            DashboardsPage(),
            MapPage(embedded: true),
            HistoryPage(embedded: true),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final t in _tabs)
              NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.selected),
                label: t.label,
              ),
          ],
        ),
      ),
    );
  }
}
