import 'package:crypto_tracker/auth/widget/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const _enLocale = Locale('en', 'GB');
const _csLocale = Locale('cs', 'CZ');

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Tracker',
      theme: ThemeData(colorSchemeSeed: Colors.amber, brightness: Brightness.dark),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [_enLocale, _csLocale],
      locale: _csLocale,
      home: AuthWrapper(),
    );
  }
}
