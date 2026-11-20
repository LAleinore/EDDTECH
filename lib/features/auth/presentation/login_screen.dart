import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/inputs.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedLang = 'ru';
  int _loginModeIndex = 0; // 0: Student, 1: Teacher, 2: Admin

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authNotifierProvider.notifier)
          .login(
            email: _emailController.text,
            password: _passwordController.text,
          );
    }
  }

  void _selectQuickAccount(UserRole role) {
    String email;
    String password;

    switch (role) {
      case UserRole.teacher:
        email = 'teacher@edumind.ai';
        password = 'Password123!';
        break;
      case UserRole.student:
        email = 'student@edumind.ai';
        password = 'Password123!';
        break;
      case UserRole.learner:
        email = 'learner@edumind.ai';
        password = 'Password123!';
        break;
      case UserRole.admin:
        email = 'admin@edumind.kz';
        password = 'admin2026';
        break;
    }

    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
      _loginModeIndex = role == UserRole.teacher
          ? 1
          : (role == UserRole.admin ? 2 : 0);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Выбран профиль: $email')),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 1),
      ),
    );

    _submit();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final loc = AppLocalizations(AppLanguage.fromCode(_selectedLang));

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language Switcher bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoSlidingSegmentedControl<String>(
                        groupValue: _selectedLang,
                        children: const {
                          'ru': Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'RU',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          'kk': Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'KK',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          'en': Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'EN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        },
                        onValueChanged: (val) {
                          if (val != null) setState(() => _selectedLang = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Brand Header
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'EduMind AI',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Интеллектуальная образовательная платформа',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.secondaryTextLight),
                  ),
                  const SizedBox(height: 24),

                  // Portal Mode Segmented Control
                  CupertinoSlidingSegmentedControl<int>(
                    groupValue: _loginModeIndex,
                    children: const {
                      0: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text(
                          'Учащийся',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      1: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text(
                          'Преподаватель',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      2: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text(
                          'Админ',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    },
                    onValueChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _loginModeIndex = val;
                          if (val == 1) {
                            _emailController.text = 'TCH-2026-AST';
                            _passwordController.text = 'Password123!';
                          } else if (val == 2) {
                            _emailController.text = 'admin@edumind.kz';
                            _passwordController.text = 'admin2026';
                          } else {
                            _emailController.text = 'student@edumind.ai';
                            _passwordController.text = 'Password123!';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  if (authState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authState.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email or Teacher ID Input
                  CustomTextField(
                    controller: _emailController,
                    label: _loginModeIndex == 1
                        ? 'Email или Код аккредитации (TCH-XXXX-KZ)'
                        : (_loginModeIndex == 2 ? 'Email Администратора' : 'Электронная почта'),
                    hint: _loginModeIndex == 1
                        ? 'TCH-2026-AST или teacher@edumind.ai'
                        : (_loginModeIndex == 2 ? 'admin@edumind.kz' : 'student@edumind.ai'),
                    prefixIcon: _loginModeIndex == 1
                        ? Icons.badge_outlined
                        : (_loginModeIndex == 2 ? Icons.admin_panel_settings_outlined : Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return loc.tr('field_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  CustomTextField(
                    controller: _passwordController,
                    label: loc.tr('password'),
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return loc.tr('field_required');
                      }
                      if (val.length < 6) return loc.tr('short_password');
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: Text(
                        loc.tr('forgot_password'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sign In Button
                  PrimaryButton(
                    text: _loginModeIndex == 1
                        ? 'Войти в портал учителей'
                        : (_loginModeIndex == 2 ? 'Войти в панель администратора' : loc.tr('login')),
                    isLoading: authState.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        loc.tr('no_account'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: Text(
                          loc.tr('register'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // QUICK ROLE ACCESS
                  const Divider(),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'БЫСТРЫЙ ДОСТУП К КАБИНЕТАМ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick login cards
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    onTap: () => _selectQuickAccount(UserRole.teacher),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.teacherAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: AppColors.teacherAccent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Кабинет Преподавателя (Daryn Ustaz)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Айгүл Серікқызы • НИШ ФМН г. Астана • TCH-2026-AST',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryTextLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.secondaryTextLight,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    onTap: () => _selectQuickAccount(UserRole.student),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.mindcareAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.psychology_rounded,
                            color: AppColors.mindcareAccent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Кабинет Учащегося (Обучение & MindCare)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Алихан Нуртаев • 10 класс • РФМШ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryTextLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.secondaryTextLight,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    onTap: () => _selectQuickAccount(UserRole.learner),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.inclusiveAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.accessibility_new_rounded,
                            color: AppColors.inclusiveAccent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Адаптивный Кабинет (Inclusive AI)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Данияр Бекенов • Озвучка TTS • Крупный шрифт',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryTextLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.secondaryTextLight,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    onTap: () => _selectQuickAccount(UserRole.admin),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: AppColors.primaryDark,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Панель Администратора (Модерация)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Проверка школ и одобрение преподавателей',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryTextLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.secondaryTextLight,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
