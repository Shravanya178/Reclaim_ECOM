import 'package:firebase_auth/firebase_auth.dart' as firebase_user;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reclaim/core/services/secure_token_storage.dart';

/// Firebase Authentication Service
/// Handles email/password and Google Sign-In authentication
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();

  factory FirebaseAuthService() => _instance;

  FirebaseAuthService._internal();

  late final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn = _initializeGoogleSignIn();
  late final SupabaseClient _supabase = Supabase.instance.client;

  /// Initialize GoogleSignIn with platform-specific configuration
  GoogleSignIn _initializeGoogleSignIn() {
    if (kIsWeb) {
      // Web requires explicit client ID
      return GoogleSignIn(
        clientId: '502383251544-35ficv7cpbklpeh0631jpvvao6evgg8s.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    } else {
      // Mobile platforms use android/iOS configuration
      return GoogleSignIn(
        scopes: ['email', 'profile'],
      );
    }
  }

  /// Get current user
  firebase_user.User? get currentUser => _firebaseAuth.currentUser;

  /// Get current user stream
  Stream<firebase_user.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ==================== EMAIL/PASSWORD AUTHENTICATION ====================

  /// Sign up with email and password
  /// Returns user if successful, throws exception on failure
  Future<firebase_user.User?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Create Firebase user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Update Firebase profile
        await user.updateDisplayName(fullName);
        await user.reload();

        // Create Supabase profile
        await _createSupabaseProfile(
          userId: user.uid,
          email: email,
          fullName: fullName,
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
      rethrow;
    }
  }

  /// Sign in with email and password
  /// Returns user if successful, throws exception on failure
  Future<firebase_user.User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null && token.isNotEmpty) {
          await SecureTokenStorage.saveToken(
            token: token,
            refreshToken: user.refreshToken,
            userId: user.uid,
          );
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
      rethrow;
    }
  }

  // ==================== GOOGLE SIGN-IN ====================

  /// Sign in with Google
  /// Returns user if successful, throws exception on failure
  Future<firebase_user.User?> signInWithGoogle() async {
    try {
      // Check if already signed in
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled');
      }

      final googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Create or update Supabase profile
        await _createSupabaseProfile(
          userId: user.uid,
          email: user.email ?? '',
          fullName: user.displayName ?? 'User',
          photoUrl: user.photoURL,
        );

        final token = await user.getIdToken();
        if (token != null && token.isNotEmpty) {
          await SecureTokenStorage.saveToken(
            token: token,
            refreshToken: user.refreshToken,
            userId: user.uid,
          );
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
      rethrow;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Sign out user
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        SecureTokenStorage.clearTokens(),
      ]);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Delete Supabase profile
        await _supabase
            .from('profiles')
            .delete()
            .eq('id', user.uid);

        // Delete Firebase user
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Create or update Supabase profile
  Future<void> _createSupabaseProfile({
    required String userId,
    required String email,
    required String fullName,
    String? photoUrl,
  }) async {
    try {
      // Check if profile already exists
      final existing = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        // Create new profile
        await _supabase.from('profiles').insert({
          'id': userId,
          'name': fullName,
          'email': email,
          'avatar_url': photoUrl,
          'role': 'student',
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Update existing profile
        await _supabase.from('profiles').update({
          'name': fullName,
          'email': email,
          'avatar_url': photoUrl,
        }).eq('id', userId);
      }
    } catch (e) {
      // Non-fatal - profile creation is best-effort
      print('Profile creation/update skipped: $e');
    }
  }

  /// Handle Firebase authentication errors
  /// Throws user-friendly exception
  Future<void> _handleFirebaseError(FirebaseAuthException e) async {
    String message;

    switch (e.code) {
      case 'weak-password':
        message = 'The password is too weak. Use 12+ characters with uppercase, lowercase, digits, and special characters.';
        break;
      case 'email-already-in-use':
        message = 'An account with this email already exists. Try signing in instead.';
        break;
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled. Contact support.';
        break;
      case 'user-not-found':
        message = 'No account found with this email.';
        break;
      case 'wrong-password':
        message = 'The password is incorrect.';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password.';
        break;
      case 'operation-not-allowed':
        message = 'This authentication method is not enabled.';
        break;
      case 'too-many-requests':
        message = 'Too many login attempts. Please try again later.';
        break;
      case 'account-exists-with-different-credential':
        message = 'An account already exists with this email but different login method.';
        break;
      default:
        message = e.message ?? 'An authentication error occurred.';
    }

    throw Exception(message);
  }

  /// Get user-friendly error message from Firebase exception
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'Password too weak. Use 12+ characters with uppercase, lowercase, digits, and special characters.';
        case 'email-already-in-use':
          return 'Email already in use. Try signing in.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-not-found':
          return 'No account with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }

    return error.toString();
  }
}
