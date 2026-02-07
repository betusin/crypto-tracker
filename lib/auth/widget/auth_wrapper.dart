import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_tracker/auth/service/auth_provider.dart';
import 'package:crypto_tracker/transaction/service/transaction_provider.dart';
import 'package:crypto_tracker/common/widget/home_screen.dart';
import 'package:crypto_tracker/auth/widget/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          // Load transactions when user is authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
            final userId = authProvider.userId;
            if (userId != null) {
              transactionProvider.loadTransactions(userId);
            }
          });
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
