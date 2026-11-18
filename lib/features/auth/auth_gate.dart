import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consent/consent_page.dart';
import '../home/home_shell.dart';
import '../settings/state/settings_provider.dart';
import 'login_page.dart';
import 'state/auth_provider.dart';

/// Decide a primeira tela: consentimento, login ou o app em si.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final hasConsent = context.select<SettingsProvider, bool>((s) => s.hasConsent);
    final status = context.select<AuthProvider, AuthStatus>((a) => a.status);
    final Widget page = !hasConsent
        ? const ConsentPage()
        : switch (status) {
            AuthStatus.unknown =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
            AuthStatus.signedOut => const LoginPage(),
            AuthStatus.signedIn => const HomeShell(),
          };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(key: ValueKey(page.runtimeType), child: page),
    );
  }
}
