import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.name,
    required this.password,
  });

  final String phone;
  final String name;
  final String password;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    TvHaptics.tap();
    final code = _code.text.trim();
    if (code.length < 6) {
      _showError('کد ۶ رقمی رو کامل وارد کن');
      return;
    }
    final ok = await ref.read(authProvider.notifier).verifyOtp(
          phone: widget.phone,
          code: code,
          password: widget.password,
          name: widget.name,
        );
    if (!mounted) return;
    if (ok) {
      TvHaptics.celebrate();
      context.go('/home');
    } else {
      _showError(ref.read(authProvider).error ?? 'کد اشتباهه');
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TvSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'کد تأیید',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: TvSpacing.xs),
              Text(
                'کد ۶ رقمی که برات فرستادیم رو وارد کن',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: TvSpacing.xl),

              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                ),
                decoration: const InputDecoration(hintText: '------'),
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
                    : const Text('تأیید و ادامه'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}