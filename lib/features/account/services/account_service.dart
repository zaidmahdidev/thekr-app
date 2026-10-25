import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// The outcome of a sign-in attempt, in words the screen can show.
enum SignInResult { success, cancelled, notAvailable, failed }

/// Optional account: signing in only unlocks backup, nothing in the app
/// depends on it.
class AccountService {
  AccountService._();
  static final AccountService instance = AccountService._();

  /// The "Web client ID" of the Firebase project (the `client_type: 3` entry
  /// in google-services.json, shown under Authentication > Google). With it
  /// the sign-in uses the phone's own account chooser. Without it the sign-in
  /// falls back to Firebase's browser-based Google flow.
  static const String googleServerClientId =
      '620286182402-db2v7u7ltpnau9e9kfj5o96chlf7jcpc.apps.googleusercontent.com';

  bool get isAvailable => Firebase.apps.isNotEmpty;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Emits the signed-in user, or null. Emits null when Firebase is not ready,
  /// so the settings screen still works offline and in tests.
  Stream<User?> get userChanges =>
      isAvailable ? _auth.userChanges() : Stream<User?>.value(null);

  User? get currentUser => isAvailable ? _auth.currentUser : null;

  bool _googleReady = false;

  /// Signs in with the phone's own Google account chooser. When that cannot
  /// work (a phone without Google Play services such as some Huawei models, or
  /// a configuration error) it moves on by itself to Firebase's web sign-in,
  /// where any Google account can be typed in. A cancel by the user stays a
  /// cancel.
  Future<SignInResult> signInWithGoogle() async {
    if (!isAvailable) return SignInResult.notAvailable;
    if (googleServerClientId.isEmpty) return _signInInBrowser();

    try {

      final google = GoogleSignIn.instance;
      // Initialising twice is not needed, so it is done once per run.
      if (!_googleReady) {
        await google.initialize(serverClientId: googleServerClientId);
        _googleReady = true;
      }
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return await _signInInBrowser();
      await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      return SignInResult.success;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return SignInResult.cancelled;
      }
      return await _signInInBrowser();
    } on FirebaseAuthException catch (e) {
      return _authFailure(e);
    } catch (_) {
      return await _signInInBrowser();
    }
  }

  Future<SignInResult> _signInInBrowser() async {
    try {
      await _auth.signInWithProvider(GoogleAuthProvider());
      return SignInResult.success;
    } on FirebaseAuthException catch (e) {
      return _authFailure(e);
    } catch (_) {
      return SignInResult.failed;
    }
  }

  SignInResult _authFailure(FirebaseAuthException e) {
    const cancelled = {
      'canceled',
      'web-context-canceled',
      'popup-closed-by-user',
    };
    return cancelled.contains(e.code)
        ? SignInResult.cancelled
        : SignInResult.failed;
  }

  /// Signs out of the account. Everything saved on the phone stays.
  Future<void> signOut() async {
    if (!isAvailable) return;
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  /// Deletes the account itself. Firebase asks for a recent sign-in first, so
  /// when it refuses the user is asked to pick the account again and the
  /// delete is retried once. The data saved on the phone stays.
  Future<bool> deleteAccount() async {
    final user = currentUser;
    if (user == null) return false;
    try {
      await user.delete();
      await _signOutGoogle();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login') return false;
    } catch (_) {
      return false;
    }

    final uid = user.uid;
    final again = await signInWithGoogle();
    final fresh = currentUser;
    if (again != SignInResult.success || fresh == null) return false;
    if (fresh.uid != uid) {
      // A different account was picked; do not delete that one.
      await signOut();
      return false;
    }
    try {
      await fresh.delete();
      await _signOutGoogle();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _signOutGoogle() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}
