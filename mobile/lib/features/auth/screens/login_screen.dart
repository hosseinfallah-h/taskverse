import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  bool _isRegister = false;
  bool _obscure = true;

  @override
  void dispose() {
    _phone.dispose();
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // ignore: avoid_print
    print('=== LOGIN_TAP: _submit() fired ===');
    TvHaptics.tap();
    final phone = _phone.text.trim();
    final password = _password.text;
    final name = _name.text.trim();
    // ignore: avoid_print
    print('=== LOGIN_TAP: phone=$phone passLen=${password.length} reg=$_isRegister ===');

    if (phone.length < 10 || password.length < 8) {
      _showError('شماره و رمز عبور را کامل وارد کن');
      return;
    }

    final auth = ref.read(authProvider.notifier);

    if (_isRegister) {
      if (name.isEmpty) {
        _showError('اسمت رو وارد کن');
        return;
      }
      final devOtp = await auth.register(phone, name);
      if (!mounted) return;
      if (devOtp != null) {
        // Dev: OTP returned. Show a BIG dialog so we can't miss it.
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('کد تست (حالت توسعه)'),
            content: SelectableText(
              devOtp,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 6,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('باشه، ادامه'),
              ),
            ],
          ),
        );
        if (!mounted) return;
        context.push('/otp', extra: {
          'phone': phone,
          'name': name,
          'password': password,
        });
      } else {
        _showError(ref.read(authProvider).error ?? 'خطا در ثبتنام');
      }
    }
  }

  void _showError(String msg) {
    TvHaptics.error();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: TvColors.rose),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TvSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: TvSpacing.xxl),
              Text(
                _isRegister ? 'خوش اومدی' : 'خوش برگشتی',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: TvSpacing.xs),
              Text(
                _isRegister
                    ? 'برای شروع، شماره‌ات رو وارد کن'
                    : 'برای ادامه وارد شو',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: TvSpacing.xl),

              if (_isRegister) ...[
                _field(
                  controller: _name,
                  label: 'اسم',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: TvSpacing.md),
              ],

              _field(
                controller: _phone,
                label: 'شماره موبایل',
                icon: Icons.phone_iphone,
                keyboard: TextInputType.phone,
                digitsOnly: true,
              ),
              const SizedBox(height: TvSpacing.md),

              _field(
                controller: _password,
                label: 'رمز عبور',
                icon: Icons.lock_outline,
                obscure: _obscure,
                trailing: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: TvColors.inkMuted,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: TvSpacing.xl),

              FilledButton(
                onPressed: auth.loading ? null : _submit,
                child: auth.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isRegister ? 'ثبت‌نام' : 'ورود'),
              ),

              const SizedBox(height: TvSpacing.md),
              TextButton(
                onPressed: () {
                  TvHaptics.tap();
                  setState(() => _isRegister = !_isRegister);
                },
                child: Text(
                  _isRegister
                      ? 'حساب داری؟ وارد شو'
                      : 'حساب نداری؟ ثبت‌نام کن',
                  style: const TextStyle(color: TvColors.brandPrimary),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    bool obscure = false,
    bool digitsOnly = false,
    Widget? trailing,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      inputFormatters: digitsOnly
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: TvColors.inkMuted),
        suffixIcon: trailing,
      ),
    );
  }
}