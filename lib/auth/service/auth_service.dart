import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // TODO(betka): make this more generic and not dependent on firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Future: Link anonymous account with email/password
  Future<UserCredential> linkWithEmailAndPassword(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(email: email, password: password);
      return await _auth.currentUser!.linkWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // Future: Link anonymous account with OAuth provider
  Future<UserCredential> linkWithProvider(AuthProvider provider) async {
    try {
      return await _auth.currentUser!.linkWithProvider(provider);
    } catch (e) {
      rethrow;
    }
  }
}
