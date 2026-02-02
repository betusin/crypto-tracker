import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInAnonymously();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to sign in: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primaryContainer, colorScheme.primary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(20)),
                    child: Icon(Icons.currency_bitcoin, size: 80, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 40),

                  // App Title
                  Text(
                    'Crypto Tracker',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    'Track your crypto portfolio',
                    style: TextStyle(fontSize: 16, color: colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 60),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signInAnonymously,
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
                          : const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info Text
                  Text(
                    'Your data will be securely stored\nand can be linked to an account later',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
