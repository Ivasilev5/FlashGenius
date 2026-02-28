import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/network/api_exception.dart';
import 'models/auth_response.dart';
import 'models/login_request.dart';
import 'models/register_request.dart';

class AuthRepository {
  AuthRepository(this._firebaseAuth, this._googleSignIn);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );
      final user = cred.user;
      if (user == null) {
        throw ApiException(message: 'User not found');
      }
      return AuthResponse(
        accessToken: '',
        refreshToken: '',
        user: AuthUser(
          id: user.uid,
          email: user.email ?? request.email,
          username: user.displayName ?? user.email ?? request.email,
        ),
      );
    } on FirebaseAuthException catch (e) {
      throw ApiException(message: e.message ?? 'Auth error');
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );
      final user = cred.user;
      if (user == null) {
        throw ApiException(message: 'User not created');
      }
      await user.updateDisplayName(request.username);
      return AuthResponse(
        accessToken: '',
        refreshToken: '',
        user: AuthUser(
          id: user.uid,
          email: user.email ?? request.email,
          username: request.username,
        ),
      );
    } on FirebaseAuthException catch (e) {
      throw ApiException(message: e.message ?? 'Auth error');
    }
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      return await _signInWithGoogleOnce();
    } on PlatformException catch (e) {
      if (_isExpiredGoogleTokenError(e)) {
        try {
          await _googleSignIn.disconnect();
        } catch (_) {}
        await _googleSignIn.signOut();
        return await _signInWithGoogleOnce();
      }
      throw ApiException(message: e.message ?? 'Google sign-in error');
    } on FirebaseAuthException catch (e) {
      throw ApiException(message: e.message ?? 'Auth error');
    }
  }

  Future<AuthResponse> _signInWithGoogleOnce() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw ApiException(message: 'Google sign-in cancelled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _firebaseAuth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) {
      throw ApiException(message: 'Google auth failed');
    }
    return AuthResponse(
      accessToken: '',
      refreshToken: '',
      user: AuthUser(
        id: user.uid,
        email: user.email ?? '',
        username: user.displayName ?? (user.email ?? ''),
      ),
    );
  }

  bool _isExpiredGoogleTokenError(PlatformException e) {
    final message = (e.message ?? '').toLowerCase();
    return e.code == 'sign_in_failed' && message.contains('id token expired');
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      await _googleSignIn.signOut();
    }
  }
}
