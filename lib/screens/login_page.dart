import 'package:flutter/material.dart';

class Credentials {
  Credentials(this.username, this.password);
  final String username;
  final String password;
}

class LoginPage extends StatelessWidget {
  const LoginPage({
    required this.onLogIn,
    required this.onSignUp,
    super.key,
  });

  final Future<void> Function(Credentials credentials) onLogIn;
  final Future<void> Function(Credentials credentials) onSignUp;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 960;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE6EEF8),
              Color(0xFFD7E7F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: isWide
                    ? Row(
                        children: [
                          const Expanded(child: _WelcomePanel()),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 460),
                                child: LoginForm(
                                  onLogIn: onLogIn,
                                  onSignUp: onSignUp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          children: [
                            if (!keyboardOpen) ...[
                              const _WelcomePanel(compact: true),
                              const SizedBox(height: 20),
                            ],
                            LoginForm(
                              onLogIn: onLogIn,
                              onSignUp: onSignUp,
                            ),
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

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1220), Color(0xFF184B84)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Welcome back to Echelon',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: compact ? 24 : 36),
          Text(
            'Friendly city driving starts here.',
            style: textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Browse real cars, plan pickup and return times, and manage '
            'every reservation from one calm dashboard.',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.45,
            ),
          ),
          SizedBox(height: compact ? 24 : 32),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroBadge(label: 'Fast pickup scheduling'),
              _HeroBadge(label: 'Astana hubs across the city'),
              _HeroBadge(label: 'Electric and premium classes'),
            ],
          ),
          SizedBox(height: compact ? 24 : 32),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today with Echelon',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                const _HeroStat(
                  value: '20',
                  label: 'cars ready across all classes',
                ),
                const SizedBox(height: 10),
                const _HeroStat(
                  value: '4.8',
                  label: 'average fleet rating this week',
                ),
                const SizedBox(height: 10),
                const _HeroStat(
                  value: '24/7',
                  label: 'support for late returns and changes',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({
    required this.onLogIn,
    required this.onSignUp,
    super.key,
  });

  final Future<void> Function(Credentials credentials) onLogIn;
  final Future<void> Function(Credentials credentials) onSignUp;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    await _submit(widget.onLogIn);
  }

  Future<void> _submitSignUp() async {
    await _submit(widget.onSignUp);
  }

  Future<void> _submit(
    Future<void> Function(Credentials credentials) action,
  ) async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await action(
        Credentials(
          _usernameController.text.trim(),
          _passwordController.text,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use your real account credentials to sign in, or create a new '
                    'account from this screen.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    onSubmitted: (_) => _submitLogin(),
                    decoration: InputDecoration(
                      labelText: 'Passcode',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submitLogin,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _submitting ? null : _submitSignUp,
                      child: const Text('Create Account'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _errorMessage == null
                              ? Icons.lock_outline
                              : Icons.error_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage ??
                                'Authentication is now connected to Firebase.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
