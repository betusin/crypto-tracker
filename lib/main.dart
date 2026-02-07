import 'package:crypto_tracker/common/widget/app_root.dart';
import 'package:crypto_tracker/firebase_options.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  IocContainer.setup();

  runApp(const AppRoot());
}
