import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_lens/applications/database/firestore_service.dart';

enum AuthStatus { uninitialized, authenticated, registering, unauthenticated }

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestoreService = FirestoreService();
  User? _user;
  String _error = '';
  AuthStatus _status = AuthStatus.uninitialized;

  String get error => _error;
  User? get user => _user;
  AuthStatus get status => _status;

  AuthProvider() {
    // Initialize the current user immediately
    _user = _auth.currentUser;

    // If there's a current user, check their registration status
    if (_user != null) {
      _checkRegistrationStatus();
    } else {
      _status = AuthStatus.unauthenticated;
    }

    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _checkRegistrationStatus();
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  // Helper method to check registration status
  Future<void> _checkRegistrationStatus() async {
    if (_user == null) return;

    final userDoc = await firestoreService.fetchData(
      collectionName: 'users',
      documentId: _user!.uid,
    );

    _status =
        userDoc == null ? AuthStatus.registering : AuthStatus.authenticated;

    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      _user = authResult.user;

      await _checkRegistrationStatus();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeRegistration({
    required String name,
    required String emergencyEmail,
  }) async {
    try {
      if (_user == null) return false;

      await firestoreService.saveUserProfile(
        user: _user!,
        name: name,
        emergencyEmail: emergencyEmail,
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        GoogleSignIn().signOut(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
    }
  }
}
