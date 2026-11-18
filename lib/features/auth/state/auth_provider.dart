import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../domain/account.dart';

enum AuthStatus { unknown, signedOut, signedIn }

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repo = repository ?? AuthRepository();

  final AuthRepository _repo;

  AuthStatus _status = AuthStatus.unknown;
  Account? _account;

  AuthStatus get status => _status;
  Account? get account => _account;

  Future<void> restore() async {
    try {
      _account = await _repo.currentSession();
    } catch (_) {
      _account = null;
    }
    _status = _account == null ? AuthStatus.signedOut : AuthStatus.signedIn;
    notifyListeners();
  }

  /// Retorna a mensagem de erro, ou null em caso de sucesso.
  Future<String?> signUp(String email, String password) =>
      _run(() => _repo.signUp(email: email, password: password));

  Future<String?> signIn(String email, String password) =>
      _run(() => _repo.signIn(email: email, password: password));

  Future<String?> _run(Future<Account> Function() action) async {
    try {
      _account = await action();
      _status = AuthStatus.signedIn;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Não foi possível concluir. Tente novamente.';
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _account = null;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    final current = _account;
    if (current == null) return;
    await _repo.deleteAccount(current.email);
    _account = null;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }
}
