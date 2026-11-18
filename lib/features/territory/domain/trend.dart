enum TrendDirection {
  up('em alta'),
  down('em queda'),
  stable('estável');

  const TrendDirection(this.label);
  final String label;
}

/// Tendência simples: compara a média da janela recente com a anterior.
class Trend {
  const Trend({
    required this.recentMean,
    required this.previousMean,
    required this.changePct,
    required this.direction,
    required this.window,
  });

  /// [values] do mais antigo para o mais recente.
  factory Trend.of(List<double> values, {int window = 7}) {
    if (values.length < 2) {
      final v = values.isEmpty ? 0.0 : values.first;
      return Trend(
        recentMean: v,
        previousMean: v,
        changePct: 0,
        direction: TrendDirection.stable,
        window: window,
      );
    }
    final half = values.length ~/ 2;
    final w = window.clamp(1, half == 0 ? 1 : half).toInt();
    final recent = values.sublist(values.length - w);
    final previous = values.sublist(values.length - 2 * w, values.length - w);
    final recentMean = _mean(recent);
    final previousMean = _mean(previous);
    final changePct = previousMean.abs() < 0.001
        ? (recentMean.abs() < 0.001 ? 0.0 : 100.0)
        : (recentMean - previousMean) / previousMean * 100;
    return Trend(
      recentMean: recentMean,
      previousMean: previousMean,
      changePct: changePct,
      direction: changePct >= 10
          ? TrendDirection.up
          : changePct <= -10
              ? TrendDirection.down
              : TrendDirection.stable,
      window: w,
    );
  }

  final double recentMean;
  final double previousMean;

  /// Variação percentual da média recente sobre a anterior.
  final double changePct;
  final TrendDirection direction;
  final int window;

  /// Ex.: "+24% em 7 dias".
  String get summary {
    final sign = changePct > 0 ? '+' : '';
    return '$sign${changePct.round()}% em $window dias';
  }

  static double _mean(List<double> xs) =>
      xs.fold(0.0, (a, b) => a + b) / xs.length;
}

double meanOf(List<double> xs) =>
    xs.isEmpty ? 0 : xs.fold(0.0, (a, b) => a + b) / xs.length;
