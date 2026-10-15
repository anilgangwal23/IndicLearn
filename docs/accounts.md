# Accounts And Profiles

## Implemented

- Email/password sign-in, registration, and password-reset email.
- Local guest sessions from the sign-in screen, without creating an account.
- Phone/SMS sign-in on Android, iOS, and web, with manual code entry and native
  automatic verification. Firebase phone sign-in is not offered on macOS.
- Native Google sign-in on Android and iOS; Firebase popup sign-in on web.
- Native macOS Google sign-in is temporarily disabled for local development.
- Apple sign-in on iOS and macOS through Firebase's Apple provider.
- Session restoration through Firebase Auth, sign-out, and an editable display name.
- Owner-scoped Firestore profiles with schema version 1 and server timestamps.

`lib/account/account.dart` contains Firebase-independent contracts. The injected
implementations live in `firebase_account.dart`; reusable screens live in
`account_screens.dart`. No project ID, service-account key, private Apple key, or
user credential is embedded in this module.

The Firebase project's provider configuration is required before real sign-in.
If Firebase cannot initialize, startup shows a retry state and offers unsigned
learning; this is not a mock authenticated account. New native plugins require
a full app rebuild, not only hot reload.

## Guest Sessions

Choose **Continue as guest** on the sign-in screen to enter lessons without
calling an authentication provider or creating a Firestore profile. The account
action on the guest lesson screen returns to sign-in. Leaving guest mode starts
a separate signed-in session; guest progress is not migrated into that account.

Guest mode is held in memory and is not restored after restarting the app.
Lesson progress is currently in memory for all users and is not persisted.
If Firebase initialization fails, **Continue without signing in** remains
available from the startup error screen.

## Firebase Project Setup

1. Create or select a Firebase project. Register each desired platform using
   its real bundle/application ID, not a guessed identifier.
2. Configure FlutterFire using the official FlutterFire CLI and console workflow:
   <https://firebase.google.com/docs/flutter/setup>. This is a manual setup step;
   no global CLI tools are installed by this implementation.
3. Startup uses `DefaultFirebaseOptions.currentPlatform` from the generated
  `lib/firebase_options.dart`. Rerun `flutterfire configure` when adding a
  platform or changing Firebase projects. Add the correct
   `GoogleService-Info.plist` to the iOS/macOS Runner targets and configure Android
   `google-services.json` plus the Google Services Gradle plugin as instructed
   by FlutterFire. Do not assume merely copying a file adds it to an Xcode target.
4. Alternatively, supply Firebase options using `--dart-define-from-file` with
   these keys: `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_PROJECT_ID`, and
   `FIREBASE_MESSAGING_SENDER_ID`. Supply `FIREBASE_AUTH_DOMAIN` for web as well.
   Use the values for the selected platform/app. All four required keys must
  be provided together. These explicit options override the generated platform
  options; without overrides, `firebase_bootstrap.dart` uses the generated file.
5. In Authentication, enable Email/Password, Phone, Google, and Apple as needed.
   Configure authorized domains and provider consent details for your environment.
6. Create a Firestore database and deploy the supplied owner-only rules to the
   selected project: `firebase deploy --only firestore:rules --project YOUR_PROJECT_ID`.
   `firebase.json` points at `firestore.rules`; never switch to public/test-mode
   rules to work around authorization errors.

Firebase client configuration is not a server credential. Nevertheless, do not
commit service-account files, Apple private keys, signing secrets, or OAuth
client secrets. Configure secret provider credentials in the appropriate consoles.

## Google

- Android: register release/debug SHA fingerprints and configure the OAuth web
  client/server ID required by the Google plugin. Re-download configuration
  after provider or fingerprint changes when necessary.
- iOS: configure the Google client ID and reversed-client-ID URL scheme
  in the Runner target. Check keychain/capability requirements.
- macOS: temporarily disabled in `FirebaseAccountService.supportsGoogle`, so
  the button is hidden and direct Google sign-in requests are rejected before
  calling the native SDK. Local builds use ad-hoc signing without Google's
  Keychain Sharing entitlement or an assigned development team. Email/password
  sign-in remains available; use the web target to test Google sign-in for now.
  To re-enable native macOS Google sign-in:
  1. Enable Google in Firebase Authentication and refresh FlutterFire/native
    configuration so the macOS OAuth client ID is available.
  2. Configure `GIDClientID` and the matching reversed-client-ID URL scheme in
    `macos/Runner/Info.plist`.
  3. Add `keychain-access-groups` with
    `$(AppIdentifierPrefix)com.google.GIDSignIn` to both macOS entitlement files.
  4. Configure development signing and a valid provisioning profile in Xcode
    for those entitlements; ad-hoc signing is insufficient.
  5. Restore macOS in `supportsGoogle`, fully rebuild, and verify real sign-in.
- The adapter accepts `GOOGLE_CLIENT_ID` and `GOOGLE_SERVER_CLIENT_ID` Dart
  defines when required; otherwise the native Google SDK uses platform setup.
- Follow the installed plugin's current platform instructions:
  <https://pub.dev/packages/google_sign_in>.

## Apple

Apple ID is an authentication provider, not a general profile database or an
automatic iCloud profile store. The app stores its own profile in Firestore.

Enable Sign in with Apple for the real App IDs in the Apple developer portal
and Xcode Signing & Capabilities for both iOS and macOS. Configure Apple's
provider in Firebase, including any required service ID/key/redirect settings.
Use provisioned capabilities rather than adding arbitrary entitlement values.

Apple may provide a name and email only during initial authorization, and email
may be a private relay address. Profile creation preserves a supplied display
name once and never overwrites an existing user-edited name at later sign-ins.
If no name is returned, the learner can edit the default name in Your profile.
The app requests only email/name scopes; no avatar or extra iCloud data is assumed.

## Phone Verification

- Use E.164 phone numbers, including country code.
- Android requires correct app verification/fingerprint configuration.
- iOS requires Firebase's APNs/app-verification and reCAPTCHA fallback setup,
  including required URL schemes, capabilities and notification forwarding.
- Web requires authorized domains and Firebase's reCAPTCHA flow.
- Configure SMS region policy, quotas, billing if required, and abuse protection
  before enabling real traffic. Use Firebase test phone numbers during development.
- The client displays SMS consent/carrier-charge text. Review production privacy
  disclosures and Firebase's processing of phone numbers before release.

See <https://firebase.google.com/docs/auth/flutter/phone-auth>.

## Profile Contract

Document path: `profiles/{firebaseUid}`. The document ID is the identity key;
`UserProfile` exposes it as `id` and serializes UTC ISO timestamps for portability.
Firestore stores timestamps as native Timestamp values:

| Field | Type | Purpose |
| --- | --- | --- |
| `schemaVersion` | integer, currently 1 | Explicit format version |
| `displayName` | string, 1-80 characters | User-editable name |
| `sourceLanguage` | string | Initially `en` |
| `targetLanguage` | string | Initially `hi` |
| `createdAt` | server timestamp | Immutable creation time |
| `updatedAt` | server timestamp | Last profile write |

Email and phone remain Firebase Auth identity attributes instead of duplicate
editable fields. Passwords, OTPs, OAuth tokens, and private Apple keys are never
written to Firestore or logs by this module.

Profile initialization is an idempotent transaction: later sign-ins do not reset
the existing name or language preferences. First profile creation requires a
connection because Firestore transactions cannot run offline. Existing profiles
can use the native SDK's cache; web persistent caching is not explicitly enabled.
This is cloud-backed profile storage, not a standalone local SQLite implementation.

Learning attempts, answers, scores, and persisted scenario progress are not part
of the profile document or implemented by this change. The scenario picker is
keyed by user ID so mounted in-memory state is not shared between accounts.

## Verification And Remaining Release Work

Run `flutter test test/account_test.dart` and
`flutter analyze lib/account lib/main.dart lib/level_loader/level_loader.dart`.
Tests use injected fake services and do not send SMS or access live accounts.

Before deployment, verify actual provider flows on each supported device,
including Apple first/subsequent authorization, automatic and manual SMS
verification, restored sessions, cancelled providers, and network failures.
Test Firestore rules with authenticated/unauthenticated clients in the Firebase
Emulator Suite: deny access to another UID, deny collection listing, reject
unknown fields and changed creation times, and allow valid owner updates.
Rules and native OAuth configurations are not certified by mocked widget tests.

Account linking, account deletion, email-verification policy, multi-factor auth,
and learning-history storage are separate follow-up work. In particular, provide
in-app account deletion and associated-data handling before an App Store release
that permits account creation. Different providers may represent separate
accounts; this module never silently merges them based on matching email.