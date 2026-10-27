import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indic_learn/account/account.dart';
import 'package:indic_learn/account/account_screens.dart';
import 'package:indic_learn/account/firebase_account.dart';
import 'package:indic_learn/ui/game_theme.dart';

void main() {
  test('Missing Apple-platform Google client ID fails before native sign-in', () {
    for (final clientId in <String?>[null, '', '   ']) {
      expect(
        () => GoogleSignInConfiguration(clientId: clientId).validate(requiresClientId: true),
        throwsA(isA<AccountFailure>().having(
          (error) => error.message, 'message', contains('Google sign-in is not configured'),
        )),
      );
    }
    expect(
      () => const GoogleSignInConfiguration(clientId: 'native-client.apps.googleusercontent.com')
          .validate(requiresClientId: true),
      returnsNormally,
    );
    expect(
      () => const GoogleSignInConfiguration().validate(requiresClientId: false),
      returnsNormally,
    );
  });

  test('Profile JSON preserves identity, preferences and UTC timestamps', () {
    final profile = UserProfile(
      id: 'stable-user-id',
      displayName: 'Learner',
      createdAt: DateTime.utc(2026, 10, 15, 10),
      updatedAt: DateTime.utc(2026, 10, 15, 11),
    );
    final restored = UserProfile.fromJson(profile.toJson());
    expect(restored.toJson(), profile.toJson());
    expect(restored.createdAt.isUtc, isTrue);
    expect(restored.targetLanguage, 'hi');
    expect(restored.schemaVersion, 1);
  });

  test('Profile rejects unsupported schema and empty identity', () {
    final json = UserProfile(
      id: 'user',
      displayName: 'Learner',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ).toJson();
    expect(
      () => UserProfile.fromJson({...json, 'schemaVersion': 2}),
      throwsFormatException,
    );
    expect(
      () => UserProfile.fromJson({...json, 'id': ''}),
      throwsFormatException,
    );
  });

  test('Authentication errors do not expose raw backend details', () {
    expect(
      accountFailure(FirebaseAuthException(code: 'invalid-credential')).message,
      'The email or password is incorrect.',
    );
    expect(
      accountFailure(
        FirebaseAuthException(
          code: 'internal-error',
          message: 'private details',
        ),
      ).message,
      isNot(contains('private details')),
    );
  });

  testWidgets(
    'Email validates locally and supports registration and password reset',
    (tester) async {
      final accounts = _Accounts();
      addTearDown(accounts.close);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildGameTheme(),
          home: SignInPage(accounts: accounts),
        ),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();
      expect(accounts.lastEmail, isNull);
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'learner@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(accounts.lastEmail, 'learner@example.com');
      await tester.tap(find.text('Create an email account'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'short',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pump();
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();
      expect(accounts.registrations, 1);
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(accounts.resetEmail, 'learner@example.com');
      expect(find.textContaining('If an account exists'), findsOneWidget);
    },
  );

  testWidgets('Phone sign-in validates number and confirms the SMS challenge', (
    tester,
  ) async {
    final accounts = _Accounts();
    addTearDown(accounts.close);
    await tester.pumpWidget(MaterialApp(home: SignInPage(accounts: accounts)));
    await tester.tap(find.text('Phone'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number'),
      '123',
    );
    await tester.tap(find.text('Send code'));
    await tester.pump();
    expect(accounts.lastPhone, isNull);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number'),
      '+919876543210',
    );
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(accounts.lastPhone, '+919876543210');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Verification code'),
      '123456',
    );
    await tester.tap(find.text('Verify and sign in'));
    await tester.pumpAndSettle();
    expect(accounts.challenge.code, '123456');
    await tester.tap(find.text('Change number or request another code'));
    await tester.pumpAndSettle();
    expect(find.text('Verification code'), findsNothing);
  });

  testWidgets('Provider buttons respect support and show safe failures', (
    tester,
  ) async {
    final accounts = _Accounts()
      ..failure = const AccountFailure('Sign-in was cancelled.');
    addTearDown(accounts.close);
    await tester.pumpWidget(MaterialApp(home: SignInPage(accounts: accounts)));
    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(accounts.googleAttempts, 1);
    expect(find.text('Sign-in was cancelled.'), findsOneWidget);
    await tester.ensureVisible(find.text('Sign in with Apple'));
    await tester.tap(find.text('Sign in with Apple'));
    await tester.pumpAndSettle();
    expect(accounts.appleAttempts, 1);
    accounts.supportsApple = false;
    accounts.supportsGoogle = false;
    accounts.supportsPhone = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SignInPage(
          key: const ValueKey('unsupported'),
          accounts: accounts,
        ),
      ),
    );
    expect(find.text('Phone'), findsNothing);
    expect(find.text('Continue with Google'), findsNothing);
    expect(find.text('Sign in with Apple'), findsNothing);
  });

  testWidgets(
    'Sign-in disables duplicate submissions and handles narrow screens',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final accounts = _Accounts()..pending = Completer<void>();
      addTearDown(accounts.close);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildGameTheme(),
          home: SignInPage(accounts: accounts),
        ),
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'learner@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
      accounts.pending!.complete();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('Guest session skips accounts and profiles and can return to sign-in', (
    tester,
  ) async {
    final accounts = _Accounts();
    final profiles = _Profiles();
    addTearDown(accounts.close);
    Widget buildApp() => MaterialApp(
      home: AccountGate(
        accounts: accounts,
        profiles: profiles,
        homeBuilder: (identity, openProfile) => Text('Account ${identity.id}'),
        guestBuilder: (signIn) => Scaffold(
          body: Column(
            children: [
              const Text('Guest lessons'),
              TextButton(onPressed: signIn, child: const Text('Sign in')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue as guest'));
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();
    expect(find.text('Guest lessons'), findsOneWidget);
    expect(accounts.currentUser, isNull);
    expect(accounts.lastEmail, isNull);
    expect(accounts.googleAttempts, 0);
    expect(accounts.signOuts, 0);
    expect(profiles.ensured, isEmpty);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.byType(SignInPage), findsOneWidget);
    expect(profiles.ensured, isEmpty);
    await tester.ensureVisible(find.text('Continue as guest'));
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(find.byType(SignInPage), findsOneWidget);
    expect(find.text('Guest lessons'), findsNothing);
    accounts.setUser(const AccountIdentity(id: 'signed-in-user'));
    await tester.pumpAndSettle();
    expect(find.text('Account signed-in-user'), findsOneWidget);
    expect(profiles.ensured, ['signed-in-user']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Session gate creates profile once, edits it and signs out', (
    tester,
  ) async {
    final accounts = _Accounts();
    final profiles = _Profiles();
    addTearDown(accounts.close);
    await tester.pumpWidget(
      MaterialApp(
        home: AccountGate(
          accounts: accounts,
          profiles: profiles,
          homeBuilder: (identity, openProfile) => Scaffold(
            body: Column(
              children: [
                Text('Learning as ${identity.id}'),
                TextButton(
                  onPressed: openProfile,
                  child: const Text('Open profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SignInPage), findsOneWidget);
    accounts.setUser(
      const AccountIdentity(id: 'first-user', email: 'learner@example.com'),
    );
    await tester.pumpAndSettle();
    expect(profiles.ensured, ['first-user']);
    expect(find.text('Learning as first-user'), findsOneWidget);
    accounts.setUser(
      const AccountIdentity(id: 'first-user', email: 'learner@example.com'),
    );
    await tester.pumpAndSettle();
    expect(profiles.ensured, ['first-user']);
    await tester.tap(find.text('Open profile'));
    await tester.pumpAndSettle();
    expect(find.text('learner@example.com'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'New learner');
    await tester.tap(find.text('Save profile'));
    await tester.pumpAndSettle();
    expect(profiles.savedName, 'New learner');
    expect(profiles.savedId, 'first-user');
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(accounts.signOuts, 1);
    expect(find.byType(ProfilePage), findsNothing);
    expect(find.byType(SignInPage), findsOneWidget);
    accounts.setUser(const AccountIdentity(id: 'second-user'));
    await tester.pumpAndSettle();
    expect(find.text('Learning as second-user'), findsOneWidget);
    expect(profiles.ensured, ['first-user', 'second-user']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Profile bootstrap can retry after a storage failure', (
    tester,
  ) async {
    final accounts = _Accounts()..setUser(const AccountIdentity(id: 'user'));
    final profiles = _Profiles()..failEnsure = true;
    addTearDown(accounts.close);
    await tester.pumpWidget(
      MaterialApp(
        home: AccountGate(
          accounts: accounts,
          profiles: profiles,
          homeBuilder: (_, _) => const Scaffold(body: Text('Ready')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Ready'), findsNothing);
    profiles.failEnsure = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Ready'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}

class _Challenge implements PhoneChallenge {
  String? code;
  @override
  Future<void> confirm(String code) async {
    this.code = code;
  }
}

class _Accounts implements AccountService {
  final _changes = StreamController<AccountIdentity?>.broadcast();
  AccountIdentity? _user;
  String? lastEmail;
  String? lastPhone;
  String? resetEmail;
  int registrations = 0;
  int googleAttempts = 0;
  int appleAttempts = 0;
  int signOuts = 0;
  AccountFailure? failure;
  Completer<void>? pending;
  final challenge = _Challenge();

  @override
  bool supportsApple = true;
  @override
  bool supportsGoogle = true;
  @override
  bool supportsPhone = true;
  @override
  AccountIdentity? get currentUser => _user;
  @override
  Stream<AccountIdentity?> get sessionChanges async* {
    yield _user;
    yield* _changes.stream;
  }

  void setUser(AccountIdentity? user) {
    _user = user;
    _changes.add(user);
  }

  Future<void> close() => _changes.close();

  @override
  Future<void> signInWithEmail(String email, String password) async {
    lastEmail = email;
    if (pending != null) await pending!.future;
    if (failure != null) throw failure!;
  }

  @override
  Future<void> createEmailAccount(String email, String password) async {
    lastEmail = email;
    registrations++;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    resetEmail = email;
  }

  @override
  Future<void> signInWithGoogle() async {
    googleAttempts++;
    if (failure != null) throw failure!;
  }

  @override
  Future<void> signInWithApple() async {
    appleAttempts++;
    if (failure != null) throw failure!;
  }

  @override
  Future<PhoneChallenge?> startPhoneSignIn(String phoneNumber) async {
    lastPhone = phoneNumber;
    return challenge;
  }

  @override
  Future<void> signOut() async {
    signOuts++;
    setUser(null);
  }
}

class _Profiles implements ProfileRepository {
  final ensured = <String>[];
  bool failEnsure = false;
  String? savedName;
  String? savedId;

  @override
  Future<void> ensureProfile(AccountIdentity identity) async {
    if (failEnsure) throw const AccountFailure('Storage unavailable');
    ensured.add(identity.id);
  }

  @override
  Stream<UserProfile?> watch(String userId) => Stream.value(
    UserProfile(
      id: userId,
      displayName: 'Learner',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  );

  @override
  Future<void> updateDisplayName(String userId, String displayName) async {
    savedId = userId;
    savedName = displayName;
  }
}
