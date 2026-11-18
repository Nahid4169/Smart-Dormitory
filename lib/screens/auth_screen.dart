import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'main_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool loading = true;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      loggedIn = prefs.getBool('is_logged_in') ?? false;
      loading = false;
    });
  }

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    if (!mounted) return;
    setState(() => loggedIn = true);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (!mounted) return;
    setState(() => loggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return loggedIn
        ? MainScreen(onLogout: logout)
        : AuthScreen(onLogin: login);
  }
}

class AuthScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const AuthScreen({super.key, required this.onLogin});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool register = false;
  bool hidePassword = true;
  bool hideConfirm = true;
  bool busy = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  Future<void> submit() async {
    final e = email.text.trim().toLowerCase();
    final p = password.text;

    if (!e.contains('@')) {
      message('Please enter a valid email address.');
      return;
    }

    if (p.length < 6) {
      message('Password must contain at least 6 characters.');
      return;
    }

    if (register && p != confirm.text) {
      message('Passwords do not match.');
      return;
    }

    setState(() => busy = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      if (register) {
        if (prefs.getString('admin_email') != null) {
          message('An account already exists. Please sign in.');
        } else {
          await prefs.setString('admin_email', e);
          await prefs.setString('admin_password', p);
          await prefs.setBool('is_logged_in', true);
          widget.onLogin();
        }
      } else {
        final savedEmail = prefs.getString('admin_email');
        final savedPassword = prefs.getString('admin_password');

        if (savedEmail == e && savedPassword == p) {
          widget.onLogin();
        } else if (savedEmail == null) {
          message('No admin account found. Create an account first.');
        } else {
          message('Incorrect email or password.');
        }
      }
    } catch (e) {
      message('Authentication error: $e');
    }

    if (mounted) setState(() => busy = false);
  }

  Widget authField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool? hidden,
    VoidCallback? toggle,
    TextInputType? keyboardType,
    TextInputAction action = TextInputAction.next,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure && (hidden ?? false),
      keyboardType: keyboardType,
      textInputAction: action,
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: true,
      style: const TextStyle(fontSize: 16, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: purple),
        suffixIcon: obscure
            ? IconButton(
          tooltip: hidden == true ? 'Show password' : 'Hide password',
          icon: Icon(
            hidden == true ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: toggle,
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF182346), bg, Color(0xFF241A43)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFF354362)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: purple.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      size: 55,
                      color: purple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SMART DORMITORY',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    register
                        ? 'Create your administrator account'
                        : 'Welcome back, Administrator',
                    style: const TextStyle(color: muted),
                  ),
                  const SizedBox(height: 30),
                  authField(
                    controller: email,
                    label: 'Email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  authField(
                    controller: password,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscure: true,
                    hidden: hidePassword,
                    toggle: () {
                      setState(() => hidePassword = !hidePassword);
                    },
                    keyboardType: TextInputType.visiblePassword,
                    action: register
                        ? TextInputAction.next
                        : TextInputAction.done,
                  ),
                  if (register) ...[
                    const SizedBox(height: 16),
                    authField(
                      controller: confirm,
                      label: 'Confirm password',
                      icon: Icons.lock_reset,
                      obscure: true,
                      hidden: hideConfirm,
                      toggle: () {
                        setState(() => hideConfirm = !hideConfirm);
                      },
                      keyboardType: TextInputType.visiblePassword,
                      action: TextInputAction.done,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: busy ? null : submit,
                      child: busy
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        register ? 'CREATE ACCOUNT' : 'SIGN IN',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () {
                      setState(() {
                        register = !register;
                        password.clear();
                        confirm.clear();
                      });
                    },
                    child: Text(
                      register
                          ? 'Already registered? Sign in'
                          : 'First time? Create admin account',
                      style: const TextStyle(color: blue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'LOCAL DEMONSTRATION AUTHENTICATION',
                    style: TextStyle(fontSize: 9, color: muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
