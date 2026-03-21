import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // TODO(betka): make this more generic and not dependent on firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInAnonymously() async => await _auth.signInAnonymously();

  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<UserCredential> linkWithEmailAndPassword(String email, String password) async {
    final credential = EmailAuthProvider.credential(email: email, password: password);
    return await _auth.currentUser!.linkWithCredential(credential);
  }

  Future<UserCredential> linkWithProvider(AuthProvider provider) async {
    return await _auth.currentUser!.linkWithProvider(provider);
  }
}
