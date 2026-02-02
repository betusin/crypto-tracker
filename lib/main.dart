import 'package:crypto_tracker/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'transaction/service/transaction_provider.dart';
import 'auth/service/auth_provider.dart';
import 'auth/widget/auth_wrapper.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(betka): use ioc with getIt instead of providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Crypto Tracker',
        theme: ThemeData(colorSchemeSeed: Colors.amber),
        home: const AuthWrapper(),
      ),
    );
  }
}
