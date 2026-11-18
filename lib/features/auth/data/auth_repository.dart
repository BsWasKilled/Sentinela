import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/account.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Autenticação local e simulada: as contas ficam só neste aparelho.
/// Em produção isso seria um serviço externo (ex.: Firebase Auth).
class AuthRepository {
  static const _accountsKey = 'accounts_v1';
  static const _sessionKey = 'session_email_v1';
  static const _iterations = 10000;

  Future<Account> signUp({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = _readAccounts(prefs);
    final key = _normalize(email);
    if (accounts.containsKey(key)) {
      throw const AuthException('Este e-mail já está cadastrado.');
    }
    final salt = _newSalt();
    final now = DateTime.now();
    final account = Account(
      email: key,
      salt: salt,
      passwordHash: _hash(password, salt),
      createdAt: now,
      consentAt: now,
    );
    accounts[key] = account;
    await _saveAccounts(prefs, accounts);
    await prefs.setString(_sessionKey, key);
    return account;
  }

  Future<Account> signIn({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final account = _readAccounts(prefs)[_normalize(email)];
    if (account == null ||
        account.passwordHash != _hash(password, account.salt)) {
      throw const AuthException('E-mail ou senha incorretos.');
    }
    await prefs.setString(_sessionKey, account.email);
    return account;
  }

  Future<Account?> currentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null) return null;
    return _readAccounts(prefs)[email];
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> deleteAccount(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = _readAccounts(prefs)..remove(_normalize(email));
    await _saveAccounts(prefs, accounts);
    await prefs.remove(_sessionKey);
  }

  String _normalize(String email) => email.trim().toLowerCase();

  Map<String, Account> _readAccounts(SharedPreferences prefs) {
    final raw = prefs.getString(_accountsKey);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map(
      (k, v) => MapEntry(k, Account.fromJson(v as Map<String, dynamic>)),
    );
  }

  Future<void> _saveAccounts(
    SharedPreferences prefs,
    Map<String, Account> accounts,
  ) {
    final map = accounts.map((k, v) => MapEntry(k, v.toJson()));
    return prefs.setString(_accountsKey, jsonEncode(map));
  }

  String _newSalt() {
    final random = Random.secure();
    return base64Encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  String _hash(String password, String salt) {
    List<int> bytes = utf8.encode('$salt:$password');
    for (var i = 0; i < _iterations; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64Encode(bytes);
  }
}
