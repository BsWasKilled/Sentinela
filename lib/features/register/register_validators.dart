/// Validações do formulário de registro (separadas para facilitar testes).
abstract final class RegisterValidators {
  static final _personalData = RegExp(
    r'[\w.+-]+@[\w-]+\.\w+|\(?\d{2}\)?\s?\d{4,5}-?\d{4}',
  );

  static String? description(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Descreva o que está acontecendo';
    if (text.length < 10) return 'Descreva com pelo menos 10 caracteres';
    if (_personalData.hasMatch(text)) {
      return 'Remova telefones ou e-mails do texto';
    }
    return null;
  }
}
