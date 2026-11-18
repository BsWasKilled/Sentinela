/// Validação dos campos de limiar (números dentro de faixas plausíveis).
abstract final class ThresholdValidators {
  static String? inRange(String? value, {required double min, required double max, String? unit}) {
    final text = value?.trim().replaceAll(',', '.') ?? '';
    if (text.isEmpty) return 'Informe um valor';
    final n = double.tryParse(text);
    if (n == null) return 'Use apenas números';
    if (n < min || n > max) {
      final u = unit == null ? '' : ' $unit';
      return 'Use entre ${_fmt(min)}$u e ${_fmt(max)}$u';
    }
    return null;
  }

  static double parse(String value) => double.parse(value.trim().replaceAll(',', '.'));

  static String _fmt(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();
}
