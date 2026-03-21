import 'package:crypto_tracker/auth/service/auth_service.dart';
import 'package:crypto_tracker/common/widget/page_wrapper.dart';
import 'package:crypto_tracker/currency/widget/bitcoin_logo.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:flutter/material.dart';
import 'package:crypto_tracker/common/constants/shared_ui_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = getIt<AuthService>();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to sign in.')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PageWrapper(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primaryContainer, colorScheme.primary],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BitcoinLogo(),
              LARGE_GAP,
              Text(
                'Crypto Tracker',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
              ),
              SMALL_GAP,
              Text(
                'Track your crypto portfolio',
                style: TextStyle(fontSize: 16, color: colorScheme.onPrimaryContainer),
              ),
              LARGE_GAP,
              Padding(padding: const EdgeInsets.all(LARGE_GAP_SIZE), child: _buildSignInButton(colorScheme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: _isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login),
                  SMALL_GAP,
                  const Text('Sign in with Google', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}
