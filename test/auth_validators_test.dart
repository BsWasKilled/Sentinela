import 'package:sentinela/features/auth/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('email', () {
    test('rejeita vazio e formato inválido', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('abc'), isNotNull);
      expect(AuthValidators.email('abc@'), isNotNull);
      expect(AuthValidators.email('abc@dominio'), isNotNull);
    });
    test('aceita e-mail válido', () {
      expect(AuthValidators.email('ana@exemplo.com'), isNull);
      expect(AuthValidators.email(' ana.silva@fiap.com.br '), isNull);
    });
  });

  group('newPassword', () {
    test('rejeita curta, sem número ou sem letra', () {
      expect(AuthValidators.newPassword(''), isNotNull);
      expect(AuthValidators.newPassword('abc123'), isNotNull);
      expect(AuthValidators.newPassword('somenteletras'), isNotNull);
      expect(AuthValidators.newPassword('12345678'), isNotNull);
    });
    test('aceita senha forte o bastante', () {
      expect(AuthValidators.newPassword('Senha1234'), isNull);
    });
  });

  group('confirmPassword', () {
    test('exige o mesmo valor', () {
      expect(AuthValidators.confirmPassword('', 'Senha1234'), isNotNull);
      expect(AuthValidators.confirmPassword('Outra1234', 'Senha1234'), isNotNull);
      expect(AuthValidators.confirmPassword('Senha1234', 'Senha1234'), isNull);
    });
  });
}
