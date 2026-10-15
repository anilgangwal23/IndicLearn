class AccountIdentity {
  const AccountIdentity({
    required this.id,
    this.email,
    this.phoneNumber,
    this.displayName,
  });

  final String id;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
    this.sourceLanguage = 'en',
    this.targetLanguage = 'hi',
    this.schemaVersion = 1,
  });

  final String id;
  final String displayName;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int schemaVersion;

  Map<String, Object> toJson() => {
    'schemaVersion': schemaVersion,
    'id': id,
    'displayName': displayName,
    'sourceLanguage': sourceLanguage,
    'targetLanguage': targetLanguage,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != 1) {
      throw const FormatException('Unsupported profile schema version.');
    }
    final id = json['id'] as String;
    final name = json['displayName'] as String;
    if (id.isEmpty || name.trim().isEmpty) {
      throw const FormatException('Profile ID and name must not be empty.');
    }
    return UserProfile(
      id: id,
      displayName: name,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    );
  }
}

class AccountFailure implements Exception {
  const AccountFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class GoogleSignInConfiguration {
  const GoogleSignInConfiguration({this.clientId, this.serverClientId});

  final String? clientId;
  final String? serverClientId;

  void validate({required bool requiresClientId}) {
    if (requiresClientId && (clientId == null || clientId!.trim().isEmpty)) {
      throw const AccountFailure(
        'Google sign-in is not configured. Enable Google in Firebase Authentication and refresh the app configuration.',
      );
    }
  }
}

abstract class PhoneChallenge {
  Future<void> confirm(String code);
}

abstract class AccountService {
  AccountIdentity? get currentUser;
  Stream<AccountIdentity?> get sessionChanges;
  bool get supportsGoogle;
  bool get supportsApple;
  bool get supportsPhone;

  Future<void> signInWithEmail(String email, String password);
  Future<void> createEmailAccount(String email, String password);
  Future<void> sendPasswordReset(String email);
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<PhoneChallenge?> startPhoneSignIn(String phoneNumber);
  Future<void> signOut();
}

abstract class ProfileRepository {
  Stream<UserProfile?> watch(String userId);
  Future<void> ensureProfile(AccountIdentity identity);
  Future<void> updateDisplayName(String userId, String displayName);
}
