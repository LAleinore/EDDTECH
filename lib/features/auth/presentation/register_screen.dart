import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/inputs.dart';
import '../../admin/data/admin_repository.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _schoolController = TextEditingController();
  final _cityController = TextEditingController();
  final _subjectController = TextEditingController();

  UserRole _selectedRole = UserRole.teacher;
  final String _selectedLang = 'ru';
  bool _consentAgreed = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _schoolController.dispose();
    _cityController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _submit() async {
    final loc = AppLocalizations(AppLanguage.fromCode(_selectedLang));
    if (!_consentAgreed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.tr('data_consent_required'))));
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      final isTeacher = _selectedRole == UserRole.teacher;
      final generatedCode = 'TCH-${(DateTime.now().millisecondsSinceEpoch % 9000 + 1000)}-KZ';

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final school = _schoolController.text.trim().isEmpty
          ? 'Общеобразовательная школа'
          : _schoolController.text.trim();
      final city = _cityController.text.trim().isEmpty
          ? 'г. Астана'
          : _cityController.text.trim();
      final subject = _subjectController.text.trim().isEmpty
          ? 'Общие дисциплины'
          : _subjectController.text.trim();

      if (isTeacher) {
        // 1. Register in admin approval queue
        await ref.read(adminApplicationsProvider.notifier).submitNewApplication(
          fullName: name,
          email: email,
          school: school,
          city: city,
          subject: subject,
          teacherCode: generatedCode,
        );

        // 2. Add to all registered users registry for admin visibility
        final newRegisteredUser = UserModel(
          id: 'user-${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email,
          role: _selectedRole,
          language: _selectedLang,
          school: school,
          city: city,
          subject: subject,
          teacherCode: generatedCode,
          isTeacherVerified: false,
          teacherStatus: 'pending',
          createdAt: DateTime.now(),
        );
        await ref.read(registeredUsersProvider.notifier).addUser(newRegisteredUser);

        setState(() => _isSubmitting = false);

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: AppColors.teacherAccent, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Заявка на аккредитацию создана!',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Учитель $name зарегистрирован в системе.',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.teacherAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.teacherAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Код учителя:', style: TextStyle(fontSize: 11, color: AppColors.secondaryTextLight)),
                          Text(generatedCode, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.teacherAccent)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Статус аккредитации:', style: TextStyle(fontSize: 11, color: AppColors.secondaryTextLight)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('⏳ На рассмотрении', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Школа: $school, $city', style: const TextStyle(fontSize: 11)),
                      Text('Предмет: $subject', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Заявка ожидает одобрения в Панели Администратора. Вы можете перейти в админку прямо сейчас и утвердить её в 1 клик:',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryTextLight),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/login');
                },
                child: const Text('На страницу входа'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final router = GoRouter.of(context);
                  Navigator.pop(ctx);
                  // Quick login as Administrator to immediately see and approve the application
                  await ref.read(authNotifierProvider.notifier).login(
                    email: 'admin@edumind.kz',
                    password: 'admin2026',
                  );
                  if (mounted) {
                    router.go('/admin');
                  }
                },
                icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                label: const Text('Открыть в Админ-панели'),
              ),
            ],
          ),
        );
      } else {
        // Students / Learners registration
        final newStudentUser = UserModel(
          id: 'user-${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email,
          role: _selectedRole,
          language: _selectedLang,
          school: school,
          city: city,
          isTeacherVerified: true,
          teacherStatus: 'approved',
          createdAt: DateTime.now(),
        );
        await ref.read(registeredUsersProvider.notifier).addUser(newStudentUser);

        ref
            .read(authNotifierProvider.notifier)
            .register(
              name: name,
              email: email,
              password: password,
              role: _selectedRole,
              language: _selectedLang,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final loc = AppLocalizations(AppLanguage.fromCode(_selectedLang));

    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('register'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                CustomTextField(
                  controller: _nameController,
                  label: loc.tr('full_name'),
                  hint: 'Иван Иванов / Айгүл Серікқызы',
                  prefixIcon: Icons.person_outline,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return loc.tr('field_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  label: loc.tr('email'),
                  hint: 'user@edumind.ai',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return loc.tr('field_required');
                    }
                    if (!val.contains('@')) return loc.tr('invalid_email');
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 20),

                // Role Selection
                const Text(
                  'Выберите роль в образовательной экосистеме',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                _RoleSelectionCard(
                  title: 'Преподаватель (Daryn Ustaz)',
                  subtitle: 'Создание поурочных планов, тестов и аналитика успеваемости',
                  icon: Icons.school_rounded,
                  color: AppColors.teacherAccent,
                  isSelected: _selectedRole == UserRole.teacher,
                  onTap: () => setState(() => _selectedRole = UserRole.teacher),
                ),
                const SizedBox(height: 8),

                _RoleSelectionCard(
                  title: 'Учащийся (Обучение & MindCare)',
                  subtitle: 'Интерактивные курсы, тренажеры и эмоциональная поддержка',
                  icon: Icons.psychology_rounded,
                  color: AppColors.mindcareAccent,
                  isSelected: _selectedRole == UserRole.student,
                  onTap: () => setState(() => _selectedRole = UserRole.student),
                ),
                const SizedBox(height: 8),

                _RoleSelectionCard(
                  title: 'Инклюзивный ученик (Inclusive AI)',
                  subtitle: 'Специальные возможности, озвучивание текста и упрощение тем',
                  icon: Icons.accessibility_new_rounded,
                  color: AppColors.inclusiveAccent,
                  isSelected: _selectedRole == UserRole.learner,
                  onTap: () => setState(() => _selectedRole = UserRole.learner),
                ),
                const SizedBox(height: 16),

                // Teacher Accreditation Fields (Conditional)
                if (_selectedRole == UserRole.teacher) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.teacherAccent.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.teacherAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified_user_outlined, color: AppColors.teacherAccent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Верификация учебного заведения',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.teacherAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Для предотвращения несанкционированного доступа заявка учителя направляется на модерацию Администрации.',
                          style: TextStyle(fontSize: 11, color: AppColors.secondaryTextLight),
                        ),
                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _schoolController,
                          label: 'Школа / Учебное заведение',
                          hint: 'Например: НИШ ФМН г. Астана / Лицей №134',
                          prefixIcon: Icons.apartment_rounded,
                          validator: (val) {
                            if (_selectedRole == UserRole.teacher && (val == null || val.trim().isEmpty)) {
                              return 'Укажите название вашей школы';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        CustomTextField(
                          controller: _cityController,
                          label: 'Город / Населенный пункт',
                          hint: 'Например: г. Астана, г. Алматы',
                          prefixIcon: Icons.location_city_rounded,
                          validator: (val) {
                            if (_selectedRole == UserRole.teacher && (val == null || val.trim().isEmpty)) {
                              return 'Укажите ваш город';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        CustomTextField(
                          controller: _subjectController,
                          label: 'Предмет преподавания',
                          hint: 'Например: Математика, Информатика, Физика',
                          prefixIcon: Icons.menu_book_rounded,
                          validator: (val) {
                            if (_selectedRole == UserRole.teacher && (val == null || val.trim().isEmpty)) {
                              return 'Укажите преподаваемый предмет';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Consent Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _consentAgreed,
                      activeColor: AppColors.primary,
                      onChanged: (val) =>
                          setState(() => _consentAgreed = val ?? false),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _consentAgreed = !_consentAgreed),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Я подтверждаю достоверность указанных данных и даю согласие на обработку образовательной информации',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                PrimaryButton(
                  text: _selectedRole == UserRole.teacher
                      ? 'Отправить заявку на аккредитацию'
                      : loc.tr('create_account'),
                  isLoading: authState.isLoading || _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc.tr('have_account'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        loc.tr('login'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleSelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      border: Border.all(
        color: isSelected ? color : AppColors.dividerLight,
        width: isSelected ? 2 : 1,
      ),
      color: isSelected ? color.withOpacity(0.06) : null,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryTextLight,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected) Icon(Icons.check_circle_rounded, color: color, size: 20),
        ],
      ),
    );
  }
}
