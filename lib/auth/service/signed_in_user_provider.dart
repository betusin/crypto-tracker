import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:crypto_tracker/auth/service/auth_service.dart';

class SignedInUserProvider {
  final AuthService _authService;
  late final BehaviorSubject<User?> _userController;
  late final StreamSubscription<User?> _authStateSubscription;

  Stream<User?> get userStream => _userController.stream;

  User? get currentUser => _userController.valueOrNull;

  SignedInUserProvider(this._authService) {
    _userController = BehaviorSubject<User?>.seeded(_authService.currentUser);
    _authStateSubscription = _authService.authStateChanges.listen((User? user) => _setUser(user));
  }

  void _setUser(User? user) => _userController.add(user);

  void dispose() {
    _authStateSubscription.cancel();
    _userController.close();
  }
}
