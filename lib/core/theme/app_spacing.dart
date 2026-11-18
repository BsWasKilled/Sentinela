import 'package:flutter/material.dart';

/// Escala de espaçamento do app (múltiplos de 4).
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Margem padrão das telas.
  static const page = EdgeInsets.fromLTRB(lg, sm, lg, xxl);

  /// Margem das telas com botão flutuante.
  static const pageWithFab = EdgeInsets.fromLTRB(lg, sm, lg, 96);

  /// Largura máxima de conteúdo em telas largas (tablet, paisagem).
  static const maxContentWidth = 720.0;

  static const radius = 16.0;
  static const radiusSm = 12.0;
}
