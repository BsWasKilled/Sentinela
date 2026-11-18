import 'package:flutter/material.dart';

import '../../features/alerts/domain/territory_alert.dart';
import 'app_spacing.dart';

/// Escolha de tema disponível nas configurações.
enum AppThemeChoice {
  system('Sistema', Icons.settings_suggest_outlined),
  light('Claro', Icons.light_mode_outlined),
  dark('Escuro', Icons.dark_mode_outlined),
  highContrast('Alto contraste', Icons.contrast);

  const AppThemeChoice(this.label, this.icon);
  final String label;
  final IconData icon;

  ThemeMode get mode => switch (this) {
        AppThemeChoice.system => ThemeMode.system,
        AppThemeChoice.light => ThemeMode.light,
        AppThemeChoice.dark => ThemeMode.dark,
        AppThemeChoice.highContrast => ThemeMode.dark,
      };
}

/// Tema do Sentinela: verde-petróleo sobre superfícies escuras, cantos
/// arredondados e tipografia com hierarquia clara.
abstract final class AppTheme {
  static const seed = Color(0xFF14B8A6);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  /// Preto puro, bordas fortes e cores saturadas (WCAG AAA para texto).
  static ThemeData get highContrast {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF5EEAD4),
      onPrimary: Color(0xFF000000),
      primaryContainer: Color(0xFF134E4A),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFFFDE68A),
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFF1F1F1F),
      onSecondaryContainer: Color(0xFFFFFFFF),
      tertiary: Color(0xFFFDBA74),
      onTertiary: Color(0xFF000000),
      tertiaryContainer: Color(0xFF3B2A14),
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: Color(0xFFFF8A80),
      onError: Color(0xFF000000),
      errorContainer: Color(0xFF4A0F0F),
      onErrorContainer: Color(0xFFFFFFFF),
      surface: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFFE6E6E6),
      surfaceContainerHighest: Color(0xFF262626),
      outline: Color(0xFFFFFFFF),
      outlineVariant: Color(0xFF9E9E9E),
      inverseSurface: Color(0xFFFFFFFF),
      onInverseSurface: Color(0xFF000000),
      inversePrimary: Color(0xFF0F766E),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      surfaceTint: Color(0xFF5EEAD4),
    );
    return _fromScheme(scheme, cardColor: const Color(0xFF0A0A0A), borderWidth: 1.5);
  }

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final base = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    final scheme = isDark
        ? base.copyWith(
            surface: const Color(0xFF0B1215),
            onSurfaceVariant: const Color(0xFFB7C4C9),
            surfaceContainerHighest: const Color(0xFF16232A),
            outlineVariant: const Color(0xFF24343C),
          )
        : base.copyWith(
            surface: const Color(0xFFF6F8F8),
            surfaceContainerHighest: const Color(0xFFE3E9EA),
          );
    return _fromScheme(
      scheme,
      cardColor: isDark ? const Color(0xFF111B20) : Colors.white,
      borderWidth: 1,
    );
  }

  static ThemeData _fromScheme(
    ColorScheme scheme, {
    required Color cardColor,
    required double borderWidth,
  }) {
    final textTheme = _textTheme(scheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: BorderSide(color: scheme.outlineVariant, width: borderWidth),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
        height: 68,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        filled: true,
        fillColor: cardColor,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: scheme.outline, width: borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: scheme.outlineVariant, width: borderWidth),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Hierarquia tipográfica: títulos mais pesados, corpo com boa altura
  /// de linha e rótulos em caixa normal.
  static TextTheme _textTheme(ColorScheme scheme) {
    final typography = Typography.material2021(platform: TargetPlatform.android);
    final base = scheme.brightness == Brightness.dark ? typography.white : typography.black;
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
      bodySmall: base.bodySmall?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  }
}

/// Cores de prioridade legíveis em fundo claro e escuro.
extension PriorityColor on AlertPriority {
  Color get color => switch (this) {
        AlertPriority.low => const Color(0xFF60A5FA),
        AlertPriority.medium => const Color(0xFFFBBF24),
        AlertPriority.high => const Color(0xFFF87171),
      };
}
