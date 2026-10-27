import 'package:flutter/material.dart';

import 'account/account.dart';
import 'account/account_screens.dart';
import 'account/firebase_bootstrap.dart';
import 'l10n/app_localizations.dart';
import 'level_loader/level_loader.dart';
import 'progress/learning_progress.dart';
import 'progress/progress_scope.dart';
import 'ui/game_theme.dart';

class LanguageGameApp extends StatelessWidget {
  const LanguageGameApp({
    super.key,
    this.accounts,
    this.profiles,
    this.progress,
  }) : assert(
         (accounts == null) == (profiles == null) &&
             (accounts == null) == (progress == null),
       );

  final AccountService? accounts;
  final ProfileRepository? profiles;
  final ProgressRepository? progress;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: buildGameTheme(),
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('hi'),
      home: accounts == null
          ? const LevelLoader()
          : AccountGate(
              accounts: accounts!,
              profiles: profiles!,
              homeBuilder: (identity, openProfile) => ProgressScope(
                key: ValueKey(identity.id),
                userId: identity.id,
                repository: progress!,
                builder: (context, snapshot, completeLevel) => LevelLoader(
                  completedLevelIds: {
                    for (final entry in snapshot.scenarios.entries)
                      entry.key: entry.value.completedLevelIds,
                  },
                  onLevelCompleted: completeLevel,
                  progressHasPendingWrites: snapshot.hasPendingWrites,
                  progressIsFromCache: snapshot.isFromCache,
                  onOpenProfile: openProfile,
                ),
              ),
              guestBuilder: (signIn) => Builder(
                builder: (context) => LevelLoader(
                  key: const ValueKey('guest'),
                  onOpenProfile: signIn,
                  accountActionLabel: AppLocalizations.of(context)!.signIn,
                ),
              ),
            ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _AccountStartup());
}

class _AccountStartup extends StatefulWidget {
  const _AccountStartup();

  @override
  State<_AccountStartup> createState() => _AccountStartupState();
}

class _AccountStartupState extends State<_AccountStartup> {
  late Future<AccountDependencies> _startup = initializeAccounts();

  @override
  Widget build(BuildContext context) => FutureBuilder<AccountDependencies>(
    future: _startup,
    builder: (context, snapshot) {
      final dependencies = snapshot.data;
      if (dependencies != null) {
        return LanguageGameApp(
          accounts: dependencies.accounts,
          profiles: dependencies.profiles,
          progress: dependencies.progress,
        );
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildGameTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('hi'),
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              appBar: AppBar(title: Text(l10n.appName)),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: snapshot.hasError
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.accountServicesUnavailable,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => setState(() {
                                _startup = initializeAccounts();
                              }),
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.retry),
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (context) => TextButton(
                                onPressed: () => Navigator.of(context).push<void>(
                                  MaterialPageRoute(
                                    builder: (_) => const LevelLoader(),
                                  ),
                                ),
                                child: Text(l10n.continueWithoutSignIn),
                              ),
                            ),
                          ],
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
