import 'package:sentinela/features/register/register_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('description', () {
    test('rejeita vazio e curto', () {
      expect(RegisterValidators.description(''), isNotNull);
      expect(RegisterValidators.description('curto'), isNotNull);
    });
    test('rejeita e-mail e telefone', () {
      expect(RegisterValidators.description('Falar com joao@email.com sobre o rio'), isNotNull);
      expect(RegisterValidators.description('Ligue para (11) 91234-5678 urgente'), isNotNull);
    });
    test('aceita descrição válida', () {
      expect(RegisterValidators.description('Rua alagada perto da praça central'), isNull);
    });
  });
}
