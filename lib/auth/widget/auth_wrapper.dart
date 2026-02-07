import 'package:crypto_tracker/auth/service/signed_in_user_provider.dart';
import 'package:crypto_tracker/common/widget/handling_stream_builder.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crypto_tracker/common/widget/home_screen.dart';
import 'package:crypto_tracker/auth/widget/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  final _signedInUserProvider = getIt<SignedInUserProvider>();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return HandlingStreamBuilder<User?>(
      stream: _signedInUserProvider.userStream,
      builder: (context, user) => user == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
