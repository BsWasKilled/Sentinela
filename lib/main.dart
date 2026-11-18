import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/state/auth_provider.dart';
import 'features/location/data/location_service.dart';
import 'features/settings/state/settings_provider.dart';
import 'features/territory/data/open_meteo_client.dart';
import 'features/territory/data/territory_repository.dart';
import 'features/territory/state/territory_provider.dart';

void main() => runApp(const SentinelaApp());

class SentinelaApp extends StatelessWidget {
  const SentinelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => OpenMeteoClient()),
        Provider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..restore()),
        ChangeNotifierProvider(
          create: (context) {
            final settings = context.read<SettingsProvider>();
            final provider = TerritoryProvider(
              flags: settings.flags,
              territory: TerritoryRepository(
                settings.flags,
                context.read<OpenMeteoClient>(),
              ),
            );
            // Só busca dados depois de saber a fonte escolhida.
            settings.loaded.whenComplete(provider.load);
            return provider;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Sentinela',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: settings.isHighContrast ? AppTheme.highContrast : AppTheme.dark,
          themeMode: settings.themeMode,
          builder: (context, child) {
            // Soma a escala do app à do sistema (acessibilidade).
            final media = MediaQuery.of(context);
            final system = media.textScaler.scale(1);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(system * settings.textScale),
              ),
              child: child!,
            );
          },
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
