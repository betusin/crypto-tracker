import 'package:crypto_tracker/auth/service/auth_service.dart';
import 'package:crypto_tracker/common/widget/handling_stream_builder.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crypto_tracker/common/widget/home_screen.dart';
import 'package:crypto_tracker/auth/widget/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return HandlingStreamBuilder<User?>(
      stream: getIt<AuthService>().authStateChanges,
      builder: (context, user) {
        if (user != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
