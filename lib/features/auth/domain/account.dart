/// Conta local. Guarda só o necessário: e-mail, hash da senha e datas.
class Account {
  const Account({
    required this.email,
    required this.salt,
    required this.passwordHash,
    required this.createdAt,
    required this.consentAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        email: json['email'] as String,
        salt: json['salt'] as String,
        passwordHash: json['passwordHash'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        consentAt: DateTime.parse(json['consentAt'] as String),
      );

  final String email;
  final String salt;
  final String passwordHash;
  final DateTime createdAt;

  /// Quando a pessoa aceitou o uso do e-mail (consentimento explícito).
  final DateTime consentAt;

  Map<String, dynamic> toJson() => {
        'email': email,
        'salt': salt,
        'passwordHash': passwordHash,
        'createdAt': createdAt.toIso8601String(),
        'consentAt': consentAt.toIso8601String(),
      };
}
