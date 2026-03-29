import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../i18n/app_i18n.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _registerMode = false;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    final auth = ref.read(authProvider.notifier);
    String? error;

    if (_registerMode) {
      error = auth.register(
        fullName: _name.text,
        email: _email.text,
        password: _password.text,
      );
    } else {
      error = auth.signIn(
        email: _email.text,
        password: _password.text,
      );
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    if (mounted) context.pop();
  }

  Future<void> _googleSignIn() async {
    final error = await ref.read(authProvider.notifier).signInWithGoogle();
    if (error != null) {
      String message;
      if (error == 'GOOGLE_CANCELLED') {
        message = ref.t('googleCancelled');
      } else if (error == 'GOOGLE_UNSUPPORTED_PLATFORM') {
        message = ref.t('googleUnsupported');
      } else if (error.startsWith('GOOGLE_FAILED::')) {
        message = '${ref.t('googleFailed')}: ${error.replaceFirst('GOOGLE_FAILED::', '')}';
      } else {
        message = error;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SamkiAppBar(title: ref.t('account'), showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ref.t('samkiAccount'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: SamkiTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _registerMode
                    ? ref.t('authSubtitleRegister')
                    : ref.t('authSubtitleSignIn'),
                style:
                    const TextStyle(color: SamkiTheme.secondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              if (_registerMode) ...[
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: ref.t('fullName')),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? ref.t('required') : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: ref.t('email')),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return ref.t('required');
                  if (!v.contains('@')) return ref.t('invalidEmail');
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(labelText: ref.t('password')),
                validator: (v) =>
                    (v == null || v.length < 4) ? ref.t('min4') : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(_registerMode ? ref.t('createAccount') : ref.t('signIn')),
                ),
              ),
              const SizedBox(height: 10),
              if (!_registerMode)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _googleSignIn,
                    icon: const Icon(Icons.g_mobiledata_rounded),
                    label: Text(ref.t('continueWithGoogle')),
                  ),
                ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () =>
                      setState(() => _registerMode = !_registerMode),
                  child: Text(_registerMode
                      ? '${ref.t('alreadyHave')}${ref.t('signIn')}'
                      : '${ref.t('noAccount')}${ref.t('register')}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
