import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../progress/firestore_progress.dart';
import '../progress/learning_progress.dart';
import 'account.dart';
import 'firebase_account.dart';

class AccountDependencies {
  const AccountDependencies({
    required this.accounts,
    required this.profiles,
    required this.progress,
  });
  final AccountService accounts;
  final ProfileRepository profiles;
  final ProgressRepository progress;
}

Future<AccountDependencies> initializeAccounts() async {
  const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  const appId = String.fromEnvironment('FIREBASE_APP_ID');
  const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  const senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  final values = [apiKey, appId, projectId, senderId];
  if (values.any((value) => value.isNotEmpty) &&
      values.any((value) => value.isEmpty)) {
    throw const AccountFailure('Firebase configuration is incomplete.');
  }
  final app = await Firebase.initializeApp(
    options: apiKey.isEmpty
        ? DefaultFirebaseOptions.currentPlatform
        : const FirebaseOptions(
            apiKey: apiKey,
            appId: appId,
            projectId: projectId,
            messagingSenderId: senderId,
            authDomain: authDomain == '' ? null : authDomain,
          ),
  );

  final firestore = FirebaseFirestore.instanceFor(app: app);

  return AccountDependencies(
    accounts: FirebaseAccountService(auth: FirebaseAuth.instanceFor(app: app)),
    profiles: FirestoreProfileRepository(firestore: firestore),
    progress: FirestoreProgressRepository(firestore: firestore),
  );
}
