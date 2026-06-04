import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/datasources/session_provider.dart';
import '../ui/theme/app_theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email  = TextEditingController();
  final _apiKey = TextEditingController();
  bool _loading = false;
  bool _hide    = true;
  String? _error;

  @override void dispose() { _email.dispose(); _apiKey.dispose(); super.dispose(); }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<SessionProvider>().login(_email.text.trim(), _apiKey.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } catch (e) {
      setState(() { _error = 'Login failed. Check your email and API key.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white30)),
            child: const Icon(Icons.flight_takeoff, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 14),
          RichText(text: const TextSpan(children: [
            TextSpan(text: 'TRAVEL', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2)),
            TextSpan(text: 'Mart',   style: TextStyle(color: Colors.white70, fontSize: 26, fontWeight: FontWeight.w300)),
          ])),
          const SizedBox(height: 4),
          const Text('Aviation Fest 2026', style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 40),
          const Text('Welcome Back', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Sign in with your Odoo account', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 32),
          // Email
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: const TextStyle(color: AppTheme.textDark),
            decoration: const InputDecoration(hintText: 'Email address', prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primary)),
          ),
          const SizedBox(height: 14),
          // API Key
          TextField(
            controller: _apiKey,
            obscureText: _hide,
            style: const TextStyle(color: AppTheme.textDark),
            decoration: InputDecoration(
              hintText: 'API Key (from Odoo account)',
              prefixIcon: const Icon(Icons.key_outlined, color: AppTheme.primary),
              suffixIcon: IconButton(
                icon: Icon(_hide ? Icons.visibility_off : Icons.visibility, color: AppTheme.textGrey),
                onPressed: () => setState(() { _hide = !_hide; }),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
              ]),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Register on the Odoo portal and use your\nAPI key to sign in here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13)),
        ]),
      )),
    );
  }
}
