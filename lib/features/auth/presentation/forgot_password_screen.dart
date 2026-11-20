import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../data/auth_repository.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_emailController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordRecovery(_emailController.text.trim());
      setState(() {
        _isLoading = false;
        _sent = true;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(AppLanguage.ru);

    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('forgot_password'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_sent) ...[
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 64,
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ссылка для восстановления пароля отправлена!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Проверьте почту ${_emailController.text} и следуйте инструкции в письме.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryTextLight,
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  text: 'Вернуться ко входу',
                  onPressed: () => context.pop(),
                ),
              ] else ...[
                Text(
                  loc.tr('forgot_password_desc'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryTextLight,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _emailController,
                  label: loc.tr('email'),
                  hint: 'example@edumind.ai',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const Spacer(),
                PrimaryButton(
                  text: loc.tr('send_recovery_link'),
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
