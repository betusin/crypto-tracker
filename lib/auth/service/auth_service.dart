import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // TODO(betka): make this more generic and not dependent on firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserCredential> linkWithEmailAndPassword(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(email: email, password: password);
      return await _auth.currentUser!.linkWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> linkWithProvider(AuthProvider provider) async {
    try {
      return await _auth.currentUser!.linkWithProvider(provider);
    } catch (e) {
      rethrow;
    }
  }
}
