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
  UserRole _selectedRole = UserRole.teacher;
  final String _selectedLang = 'ru';
  bool _consentAgreed = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final loc = AppLocalizations(AppLanguage.fromCode(_selectedLang));
    if (!_consentAgreed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.tr('data_consent_required'))));
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authNotifierProvider.notifier)
          .register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            role: _selectedRole,
            language: _selectedLang,
          );
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
                    if (val == null || val.trim().isEmpty)
                      return loc.tr('field_required');
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
                    if (val == null || val.trim().isEmpty)
                      return loc.tr('field_required');
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
                    if (val == null || val.trim().isEmpty)
                      return loc.tr('field_required');
                    if (val.length < 6) return loc.tr('short_password');
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Role Selection
                Text(
                  loc.tr('select_role'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                _RoleSelectionCard(
                  title: loc.tr('role_teacher'),
                  subtitle: loc.tr('module_teacher_desc'),
                  icon: Icons.school_outlined,
                  color: AppColors.teacherAccent,
                  isSelected: _selectedRole == UserRole.teacher,
                  onTap: () => setState(() => _selectedRole = UserRole.teacher),
                ),
                const SizedBox(height: 8),

                _RoleSelectionCard(
                  title: loc.tr('role_student'),
                  subtitle: loc.tr('module_mindcare_desc'),
                  icon: Icons.spa_outlined,
                  color: AppColors.mindcareAccent,
                  isSelected: _selectedRole == UserRole.student,
                  onTap: () => setState(() => _selectedRole = UserRole.student),
                ),
                const SizedBox(height: 8),

                _RoleSelectionCard(
                  title: loc.tr('role_learner'),
                  subtitle: loc.tr('module_inclusive_desc'),
                  icon: Icons.accessibility_new_outlined,
                  color: AppColors.inclusiveAccent,
                  isSelected: _selectedRole == UserRole.learner,
                  onTap: () => setState(() => _selectedRole = UserRole.learner),
                ),
                const SizedBox(height: 20),

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
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            loc.tr('data_consent'),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                PrimaryButton(
                  text: loc.tr('create_account'),
                  isLoading: authState.isLoading,
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
          if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
        ],
      ),
    );
  }
}
