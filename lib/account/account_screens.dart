import 'package:flutter/material.dart';

import 'account.dart';

String _errorMessage(Object error) => error is AccountFailure
    ? error.message
    : 'Unable to reach your account. Check your connection and try again.';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.accounts, this.onContinueAsGuest});
  final AccountService accounts;
  final VoidCallback? onContinueAsGuest;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _code = TextEditingController();
  PhoneChallenge? _challenge;
  bool _phoneMode = false;
  bool _register = false;
  bool _busy = false;
  bool _hidePassword = true;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
      ? null
      : 'Enter a valid email address.';

  Future<void> _perform(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await operation();
    } catch (error) {
      if (mounted) setState(() => _error = _errorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    _perform(() async {
      if (_phoneMode) {
        if (_challenge != null) {
          await _challenge!.confirm(_code.text);
        } else {
          final challenge = await widget.accounts.startPhoneSignIn(_phone.text);
          if (mounted) setState(() => _challenge = challenge);
        }
      } else if (_register) {
        await widget.accounts.createEmailAccount(_email.text, _password.text);
      } else {
        await widget.accounts.signInWithEmail(_email.text, _password.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.accounts;
    return Scaffold(
      appBar: AppBar(title: const Text('IndicLearn')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _register && !_phoneMode
                            ? 'Create your account'
                            : 'Sign in',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      if (accounts.supportsPhone) ...[
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: false,
                              icon: Icon(Icons.email_outlined),
                              label: Text('Email'),
                            ),
                            ButtonSegment(
                              value: true,
                              icon: Icon(Icons.phone_outlined),
                              label: Text('Phone'),
                            ),
                          ],
                          selected: {_phoneMode},
                          onSelectionChanged: _busy
                              ? null
                              : (selection) => setState(() {
                                  _phoneMode = selection.single;
                                  _error = null;
                                  _notice = null;
                                  _challenge = null;
                                  _code.clear();
                                  _form.currentState?.reset();
                                }),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (!_phoneMode) ...[
                        TextFormField(
                          controller: _email,
                          enabled: !_busy,
                          autofillHints: const [AutofillHints.email],
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          enabled: !_busy,
                          obscureText: _hidePassword,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          autofillHints: [
                            _register
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              tooltip: _hidePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your password.';
                            }
                            if (_register && value.length < 8) {
                              return 'Use at least 8 characters.';
                            }
                            return null;
                          },
                          onFieldSubmitted: _busy ? null : (_) => _submit(),
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _phone,
                          enabled: !_busy && _challenge == null,
                          keyboardType: TextInputType.phone,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            hintText: '+919876543210',
                          ),
                          validator: (value) =>
                              RegExp(r'^\+[1-9]\d{7,14}$')
                                  .hasMatch(value?.trim() ?? '')
                              ? null
                              : 'Include the country code, for example +91.',
                        ),
                        if (_challenge != null) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _code,
                            enabled: !_busy,
                            keyboardType: TextInputType.number,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            decoration: const InputDecoration(
                              labelText: 'Verification code',
                            ),
                            validator: (value) =>
                                RegExp(r'^\d{6}$').hasMatch(value?.trim() ?? '')
                                ? null
                                : 'Enter the 6-digit code.',
                            onFieldSubmitted: _busy ? null : (_) => _submit(),
                          ),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => setState(() {
                                    _challenge = null;
                                    _code.clear();
                                    _error = null;
                                  }),
                            child: const Text(
                              'Change number or request another code',
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Text(
                          'By requesting a code, you agree to receive a verification SMS. Carrier charges may apply.',
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          semanticsLabel: _error,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      if (_notice != null) ...[
                        const SizedBox(height: 16),
                        Text(_notice!),
                      ],
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _busy ? null : _submit,
                        icon: _busy
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _phoneMode ? Icons.sms_outlined : Icons.login,
                              ),
                        label: Text(
                          _phoneMode
                              ? (_challenge == null
                                    ? 'Send code'
                                    : 'Verify and sign in')
                              : (_register ? 'Create account' : 'Sign in'),
                        ),
                      ),
                      if (!_phoneMode) ...[
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => setState(() {
                                  _register = !_register;
                                  _error = null;
                                  _notice = null;
                                  _password.clear();
                                }),
                          child: Text(
                            _register
                                ? 'Already have an account? Sign in'
                                : 'Create an email account',
                          ),
                        ),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () {
                                  if (_validateEmail(_email.text) != null) {
                                    setState(
                                      () => _error =
                                          'Enter your email address first.',
                                    );
                                    return;
                                  }
                                  _perform(() async {
                                    await accounts.sendPasswordReset(
                                      _email.text,
                                    );
                                    if (mounted) {
                                      setState(
                                        () => _notice = 'If an account exists, a password-reset email has been sent.',
                                      );
                                    }
                                  });
                                },
                          child: const Text('Forgot password?'),
                        ),
                      ],
                      if (accounts.supportsGoogle ||
                          accounts.supportsApple) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                      ],
                      if (accounts.supportsGoogle)
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _perform(accounts.signInWithGoogle),
                          icon: const Icon(Icons.login),
                          label: const Text('Continue with Google'),
                        ),
                      if (accounts.supportsApple) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _perform(accounts.signInWithApple),
                          icon: const Icon(Icons.apple),
                          label: const Text('Sign in with Apple'),
                        ),
                      ],
                      if (widget.onContinueAsGuest != null) ...[
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _busy ? null : widget.onContinueAsGuest,
                          icon: const Icon(Icons.person_outline),
                          label: const Text('Continue as guest'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.identity,
    required this.accounts,
    required this.profiles,
  });
  final AccountIdentity identity;
  final AccountService accounts;
  final ProfileRepository profiles;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _name = TextEditingController();
  late final Stream<UserProfile?> _profile;
  bool _initialized = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _profile = widget.profiles.watch(widget.identity.id);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _perform(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await operation();
    } catch (error) {
      if (mounted) setState(() => _error = _errorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your profile')),
    body: StreamBuilder<UserProfile?>(
      stream: _profile,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (!_initialized && profile != null) {
          _name.text = profile.displayName;
          _initialized = true;
        }
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (snapshot.hasError)
                    const Text(
                      'Unable to load your profile. Check your connection.',
                    )
                  else if (profile == null)
                    const LinearProgressIndicator(),
                  TextField(
                    controller: _name,
                    enabled: !_busy && profile != null,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                    ),
                  ),
                  if (widget.identity.email != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.email_outlined),
                      title: Text(widget.identity.email!),
                    ),
                  if (widget.identity.phoneNumber != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.phone_outlined),
                      title: Text(widget.identity.phoneNumber!),
                    ),
                  if (_error != null)
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _busy || profile == null
                        ? null
                        : () => _perform(() async {
                            final name = _name.text.trim();
                            if (name.isEmpty || name.length > 80) {
                              throw const AccountFailure(
                                'Use a name between 1 and 80 characters.',
                              );
                            }
                            await widget.profiles.updateDisplayName(
                              widget.identity.id,
                              name,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile saved')),
                              );
                            }
                          }),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save profile'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _perform(() async {
                            await widget.accounts.signOut();
                            if (context.mounted) {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }
                          }),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign out'),
                  ),
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class AccountGate extends StatefulWidget {
  const AccountGate({
    super.key,
    required this.accounts,
    required this.profiles,
    required this.homeBuilder,
    this.guestBuilder,
  });
  final AccountService accounts;
  final ProfileRepository profiles;
  final Widget Function(AccountIdentity identity, VoidCallback openProfile)
  homeBuilder;
  final Widget Function(VoidCallback signIn)? guestBuilder;

  @override
  State<AccountGate> createState() => _AccountGateState();
}

class _AccountGateState extends State<AccountGate> {
  bool _guest = false;
  late final Stream<AccountIdentity?> _sessions =
      widget.accounts.sessionChanges;

  @override
  Widget build(BuildContext context) => StreamBuilder<AccountIdentity?>(
    stream: _sessions,
    initialData: widget.accounts.currentUser,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Scaffold(
          body: Center(
            child: Text(
              'Account session unavailable. Restart the app to retry.',
            ),
          ),
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting &&
          !snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final identity = snapshot.data;
      if (identity == null) {
        final guestBuilder = widget.guestBuilder;
        if (_guest && guestBuilder != null) {
          return guestBuilder(() => setState(() => _guest = false));
        }
        return SignInPage(
          accounts: widget.accounts,
          onContinueAsGuest: guestBuilder == null
              ? null
              : () => setState(() => _guest = true),
        );
      }
      return _ProfileBootstrap(
        key: ValueKey(identity.id),
        identity: identity,
        accounts: widget.accounts,
        profiles: widget.profiles,
        homeBuilder: widget.homeBuilder,
      );
    },
  );
}

class _ProfileBootstrap extends StatefulWidget {
  const _ProfileBootstrap({
    super.key,
    required this.identity,
    required this.accounts,
    required this.profiles,
    required this.homeBuilder,
  });
  final AccountIdentity identity;
  final AccountService accounts;
  final ProfileRepository profiles;
  final Widget Function(AccountIdentity, VoidCallback) homeBuilder;

  @override
  State<_ProfileBootstrap> createState() => _ProfileBootstrapState();
}

class _ProfileBootstrapState extends State<_ProfileBootstrap> {
  late Future<void> _ready = widget.profiles.ensureProfile(widget.identity);

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _ready,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          appBar: AppBar(title: const Text('Your account')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Your profile could not be loaded. Check your connection.',
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => setState(() {
                    _ready = widget.profiles.ensureProfile(widget.identity);
                  }),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await widget.accounts.signOut();
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sign-out failed. Try again.'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        );
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return widget.homeBuilder(widget.identity, () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ProfilePage(
              identity: widget.identity,
              accounts: widget.accounts,
              profiles: widget.profiles,
            ),
          ),
        );
      });
    },
  );
}
