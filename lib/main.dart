import 'package:flutter/material.dart';

import 'account/account.dart';
import 'account/account_screens.dart';
import 'account/firebase_bootstrap.dart';
import 'level_loader/level_loader.dart';
import 'ui/game_theme.dart';

class LanguageGameApp extends StatelessWidget {
  const LanguageGameApp({super.key, this.accounts, this.profiles})
    : assert((accounts == null) == (profiles == null));

  final AccountService? accounts;
  final ProfileRepository? profiles;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Language Game',
      theme: buildGameTheme(),
      home: accounts == null
          ? const LevelLoader()
          : AccountGate(
              accounts: accounts!,
              profiles: profiles!,
              homeBuilder: (identity, openProfile) => LevelLoader(
                key: ValueKey(identity.id),
                onOpenProfile: openProfile,
              ),
              guestBuilder: (signIn) => LevelLoader(
                key: const ValueKey('guest'),
                onOpenProfile: signIn,
                accountActionLabel: 'Sign in',
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
        );
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildGameTheme(),
        home: Scaffold(
          appBar: AppBar(title: const Text('IndicLearn')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: snapshot.hasError
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Account services unavailable. Firebase setup or a connection may be required.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => setState(() {
                            _startup = initializeAccounts();
                          }),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) => TextButton(
                            onPressed: () => Navigator.of(context).push<void>(
                              MaterialPageRoute(
                                builder: (_) => const LevelLoader(),
                              ),
                            ),
                            child: const Text('Continue without signing in'),
                          ),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        ),
      );
    },
  );
}
