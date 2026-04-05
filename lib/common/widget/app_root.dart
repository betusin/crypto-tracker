import 'package:crypto_tracker/auth/widget/auth_wrapper.dart';
import 'package:flutter/material.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Tracker',
      theme: ThemeData(colorSchemeSeed: Colors.amber, brightness: Brightness.dark),
      home: AuthWrapper(),
    );
  }
}
