import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'account.dart';

AccountFailure accountFailure(Object error) {
  if (error is AccountFailure) return error;
  if (error is FirebaseAuthException) {
    return AccountFailure(switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'The email or password is incorrect.',
      'email-already-in-use' => 'An account already uses this email address.',
      'weak-password' => 'Use a stronger password with at least 8 characters.',
      'invalid-phone-number' => 'Use a phone number with its country code.',
      'invalid-verification-code' => 'The verification code is incorrect.',
      'session-expired' ||
      'code-expired' => 'The code expired. Request a new one.',
      'too-many-requests' ||
      'quota-exceeded' => 'Too many attempts. Please try again later.',
      'network-request-failed' => 'Check your connection and try again.',
      'account-exists-with-different-credential' =>
        'Use the original sign-in method for this account.',
      'operation-not-allowed' => 'This sign-in method has not been enabled.',
      'popup-closed-by-user' ||
      'web-context-cancelled' ||
      'canceled' => 'Sign-in was cancelled.',
      'popup-blocked' => 'Your browser blocked the sign-in popup.',
      'user-disabled' => 'This account is disabled.',
      _ => 'Sign-in could not be completed. Please try again.',
    });
  }
  if (error is GoogleSignInException) {
    return AccountFailure(
      error.code == GoogleSignInExceptionCode.canceled
          ? 'Sign-in was cancelled.'
          : 'Google sign-in is unavailable. Please try again.',
    );
  }
  return const AccountFailure('The account service is unavailable. Try again.');
}

class FirebaseAccountService implements AccountService {
  FirebaseAccountService({required this.auth, GoogleSignIn? google})
    : _google = google ?? GoogleSignIn.instance;

  final FirebaseAuth auth;
  final GoogleSignIn _google;
  Future<void>? _googleReady;

  AccountIdentity? _identity(User? user) => user == null
      ? null
      : AccountIdentity(
          id: user.uid,
          email: user.email,
          phoneNumber: user.phoneNumber,
          displayName: user.displayName,
        );

  @override
  AccountIdentity? get currentUser => _identity(auth.currentUser);

  @override
  Stream<AccountIdentity?> get sessionChanges =>
      auth.userChanges().map(_identity);

  @override
  bool get supportsGoogle =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  @override
  bool get supportsApple =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  bool get supportsPhone =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error) {
      throw accountFailure(error);
    }
  }

  @override
  Future<void> signInWithEmail(String email, String password) => _run(() async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  });

  @override
  Future<void> createEmailAccount(String email, String password) =>
      _run(() async {
        await auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      });

  @override
  Future<void> sendPasswordReset(String email) =>
      _run(() => auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signInWithGoogle() => _run(() async {
    if (!supportsGoogle) {
      throw const AccountFailure(
        'Google sign-in is unavailable on this device.',
      );
    }
    if (kIsWeb) {
      await auth.signInWithPopup(GoogleAuthProvider());
      return;
    }
    const overrideClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
    const serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    final configuration = GoogleSignInConfiguration(
      clientId: overrideClientId.isNotEmpty
          ? overrideClientId
          : auth.app.options.iosClientId,
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
    configuration.validate(requiresClientId: supportsApple);
    _googleReady ??= _google.initialize(
      clientId: configuration.clientId,
      serverClientId: configuration.serverClientId,
    );
    try {
      await _googleReady;
    } catch (_) {
      _googleReady = null;
      rethrow;
    }
    final account = await _google.authenticate();
    final token = account.authentication.idToken;
    if (token == null) {
      throw const AccountFailure('Google did not return a sign-in token.');
    }
    await auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: token),
    );
  });

  @override
  Future<void> signInWithApple() => _run(() async {
    if (!supportsApple) {
      throw const AccountFailure(
        'Apple sign-in is unavailable on this device.',
      );
    }
    await auth.signInWithProvider(
      AppleAuthProvider()
        ..addScope('email')
        ..addScope('name'),
    );
  });

  @override
  Future<PhoneChallenge?> startPhoneSignIn(String phoneNumber) =>
      _run(() async {
        if (!supportsPhone) {
          throw const AccountFailure(
            'Phone sign-in is unavailable on this device.',
          );
        }
        if (kIsWeb) {
          final result = await auth.signInWithPhoneNumber(phoneNumber.trim());
          return _PhoneChallenge(
            (code) => _run(() async {
              await result.confirm(code);
            }),
          );
        }
        final challenge = Completer<PhoneChallenge?>();
        void codeReady(String verificationId) {
          if (challenge.isCompleted) return;
          challenge.complete(
            _PhoneChallenge(
              (code) => _run(() async {
                await auth.signInWithCredential(
                  PhoneAuthProvider.credential(
                    verificationId: verificationId,
                    smsCode: code,
                  ),
                );
              }),
            ),
          );
        }

        final result = challenge.future.timeout(
          const Duration(seconds: 75),
          onTimeout: () =>
              throw const AccountFailure('SMS request timed out. Try again.'),
        );
        unawaited(
          auth
              .verifyPhoneNumber(
                phoneNumber: phoneNumber.trim(),
                timeout: const Duration(seconds: 60),
                verificationCompleted: (credential) async {
                  try {
                    await auth.signInWithCredential(credential);
                    if (!challenge.isCompleted) challenge.complete(null);
                  } catch (error) {
                    if (!challenge.isCompleted) {
                      challenge.completeError(accountFailure(error));
                    }
                  }
                },
                verificationFailed: (error) {
                  if (!challenge.isCompleted) {
                    challenge.completeError(accountFailure(error));
                  }
                },
                codeSent: (verificationId, _) => codeReady(verificationId),
                codeAutoRetrievalTimeout: codeReady,
              )
              .catchError((Object error) {
                if (!challenge.isCompleted) {
                  challenge.completeError(accountFailure(error));
                }
              }),
        );
        return result;
      });

  @override
  Future<void> signOut() => _run(() async {
    await auth.signOut();
    if (!kIsWeb && _googleReady != null) {
      try {
        await _google.signOut();
      } catch (_) {
        return;
      }
    }
  });
}

class _PhoneChallenge implements PhoneChallenge {
  _PhoneChallenge(this._confirm);
  final Future<void> Function(String) _confirm;

  @override
  Future<void> confirm(String code) => _confirm(code.trim());
}

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({required this.firestore});

  final FirebaseFirestore firestore;

  DocumentReference<Map<String, dynamic>> _document(String id) =>
      firestore.collection('profiles').doc(id);

  @override
  Stream<UserProfile?> watch(String userId) =>
      _document(userId).snapshots().map((snapshot) {
        final data = snapshot.data();
        if (data == null) return null;
        final createdAt = data['createdAt'];
        final updatedAt = data['updatedAt'];
        if (createdAt is! Timestamp || updatedAt is! Timestamp) return null;
        return UserProfile.fromJson({
          ...data,
          'id': snapshot.id,
          'createdAt': createdAt.toDate().toUtc().toIso8601String(),
          'updatedAt': updatedAt.toDate().toUtc().toIso8601String(),
        });
      });

  @override
  Future<void> ensureProfile(AccountIdentity identity) async {
    final document = _document(identity.id);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      if (snapshot.exists) return;
      final name = identity.displayName?.trim();
      transaction.set(document, {
        'schemaVersion': 1,
        'displayName': name == null || name.isEmpty
            ? 'Learner'
            : name.substring(0, name.length.clamp(0, 80)),
        'sourceLanguage': 'en',
        'targetLanguage': 'hi',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> updateDisplayName(String userId, String displayName) async {
    final name = displayName.trim();
    if (name.isEmpty || name.length > 80) {
      throw const AccountFailure('Use a name between 1 and 80 characters.');
    }
    await _document(
      userId,
    ).update({'displayName': name, 'updatedAt': FieldValue.serverTimestamp()});
  }
}
