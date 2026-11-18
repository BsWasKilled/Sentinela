import 'package:sentinela/features/auth/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = AuthRepository();
  });

  test('cadastra, abre sessão e não guarda a senha em texto', () async {
    await repo.signUp(email: 'Ana@Exemplo.com', password: 'Senha1234');
    final session = await repo.currentSession();
    expect(session?.email, 'ana@exemplo.com');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('accounts_v1'), isNot(contains('Senha1234')));
  });

  test('login funciona com a senha certa e falha com a errada', () async {
    await repo.signUp(email: 'ana@exemplo.com', password: 'Senha1234');
    await repo.signOut();
    expect(await repo.currentSession(), isNull);

    await expectLater(
      repo.signIn(email: 'ana@exemplo.com', password: 'Errada123'),
      throwsA(isA<AuthException>()),
    );
    final account =
        await repo.signIn(email: 'ANA@exemplo.com', password: 'Senha1234');
    expect(account.email, 'ana@exemplo.com');
  });

  test('não permite cadastrar o mesmo e-mail duas vezes', () async {
    await repo.signUp(email: 'ana@exemplo.com', password: 'Senha1234');
    await expectLater(
      repo.signUp(email: 'ana@exemplo.com', password: 'Outra1234'),
      throwsA(isA<AuthException>()),
    );
  });

  test('excluir a conta encerra a sessão e impede novo login', () async {
    await repo.signUp(email: 'ana@exemplo.com', password: 'Senha1234');
    await repo.deleteAccount('ana@exemplo.com');
    expect(await repo.currentSession(), isNull);
    await expectLater(
      repo.signIn(email: 'ana@exemplo.com', password: 'Senha1234'),
      throwsA(isA<AuthException>()),
    );
  });
}
