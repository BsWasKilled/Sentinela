import 'package:flutter/material.dart';

import '../../features/alerts/domain/territory_alert.dart';
import '../../features/alerts/presentation/alert_detail_page.dart';
import '../../features/auth/auth_gate.dart';
import '../../features/auth/signup_page.dart';
import '../../features/dashboards/climate_dashboard_page.dart';
import '../../features/dashboards/indicator_detail_page.dart';
import '../../features/dashboards/resources_dashboard_page.dart';
import '../../features/dashboards/services_dashboard_page.dart';
import '../../features/history/history_page.dart';
import '../../features/map/map_page.dart';
import '../../features/method/method_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/register/register_alert_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/thresholds/thresholds_page.dart';
import '../../features/territory/domain/indicator.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.signup => const SignupPage(),
      AppRoutes.history => const HistoryPage(),
      AppRoutes.register => const RegisterAlertPage(),
      AppRoutes.alertDetail =>
        AlertDetailPage(alert: settings.arguments as TerritoryAlert),
      AppRoutes.profile => const ProfilePage(),
      AppRoutes.settings => const SettingsPage(),
      AppRoutes.dashboardClimate => const ClimateDashboardPage(),
      AppRoutes.dashboardResources => const ResourcesDashboardPage(),
      AppRoutes.dashboardServices => const ServicesDashboardPage(),
      AppRoutes.indicatorDetail =>
        IndicatorDetailPage(indicator: settings.arguments as Indicator),
      AppRoutes.map => const MapPage(),
      AppRoutes.thresholds => const ThresholdsPage(),
      AppRoutes.method => const MethodPage(),
      _ => const AuthGate(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
