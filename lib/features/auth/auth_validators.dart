/// Validações dos formulários de login e cadastro.
abstract final class AuthValidators {
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final _letter = RegExp(r'[A-Za-z]');
  static final _digit = RegExp(r'\d');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Informe seu e-mail';
    if (!_email.hasMatch(text)) return 'Informe um e-mail válido';
    return null;
  }

  /// Regras para criar uma senha nova.
  static String? newPassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Informe uma senha';
    if (text.length < 8) return 'Use ao menos 8 caracteres';
    if (!_letter.hasMatch(text) || !_digit.hasMatch(text)) {
      return 'Use letras e números';
    }
    return null;
  }

  /// No login basta a senha não estar vazia.
  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe sua senha';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirme a senha';
    if (value != original) return 'As senhas não conferem';
    return null;
  }
}
