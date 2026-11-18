import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/password_field.dart';
import 'auth_validators.dart';
import 'state/auth_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    final error =
        await context.read<AuthProvider>().signUp(_email.text, _password.text);
    if (!mounted) return;
    if (error == null) {
      // A sessão já foi aberta: volta à raiz, que agora mostra o início.
      navigator.popUntil((route) => route.isFirst);
      return;
    }
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _password,
                      label: 'Senha',
                      validator: AuthValidators.newPassword,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mínimo de 8 caracteres, com letras e números.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _confirm,
                      label: 'Confirmar senha',
                      validator: (v) =>
                          AuthValidators.confirmPassword(v, _password.text),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 16),
                    FormField<bool>(
                      initialValue: false,
                      validator: (v) => v == true
                          ? null
                          : 'É necessário concordar para criar a conta',
                      builder: (field) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            value: field.value ?? false,
                            onChanged: field.didChange,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Concordo com o uso do meu e-mail apenas para '
                              'identificar minha conta. Os alertas que eu '
                              'registrar continuam anônimos.',
                            ),
                          ),
                          if (field.hasError)
                            Text(
                              field.errorText!,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Criar conta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
