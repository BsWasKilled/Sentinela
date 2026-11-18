import 'package:sentinela/features/territory/domain/trend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('série estável fica como estável', () {
    final t = Trend.of(List.filled(14, 10.0));
    expect(t.direction, TrendDirection.stable);
    expect(t.changePct, 0);
  });

  test('semana recente 50% maior fica em alta', () {
    final t = Trend.of([...List.filled(7, 10.0), ...List.filled(7, 15.0)]);
    expect(t.direction, TrendDirection.up);
    expect(t.changePct, closeTo(50, 0.01));
    expect(t.summary, '+50% em 7 dias');
  });

  test('queda de 20% fica em queda', () {
    final t = Trend.of([...List.filled(7, 10.0), ...List.filled(7, 8.0)]);
    expect(t.direction, TrendDirection.down);
  });

  test('série curta não quebra', () {
    expect(Trend.of([]).direction, TrendDirection.stable);
    expect(Trend.of([5]).direction, TrendDirection.stable);
    expect(Trend.of([5, 20]).direction, TrendDirection.up);
  });
}
