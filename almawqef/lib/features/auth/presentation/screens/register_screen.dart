import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isArtisan = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.isAuthenticated && prev?.isAuthenticated != true) {
        context.go(next.user?.role == 'ARTISAN' ? '/artisan-dashboard' : '/home');
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(Icons.person_add_rounded, size: 44, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        const Text('إنشاء حساب', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('انضم إلى الميقف', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Role toggle
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.bgMuted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: _roleToggle('زبون', !_isArtisan, false)),
                                  const SizedBox(width: 4),
                                  Expanded(child: _roleToggle('حرفي', _isArtisan, true)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            TextFormField(
                              controller: _nameController,
                              textDirection: TextDirection.rtl,
                              decoration: const InputDecoration(
                                labelText: 'الاسم الكامل',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'أدخل اسمك' : null,
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              decoration: const InputDecoration(
                                labelText: 'رقم الهاتف',
                                prefixIcon: Icon(Icons.phone_outlined),
                                hintText: '+212 6XX XX XX XX',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'أدخل رقم هاتفك' : null,
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                              decoration: const InputDecoration(
                                labelText: 'البريد الإلكتروني (اختياري)',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) => v == null || v.length < 6 ? '6 أحرف على الأقل' : null,
                            ),
                            const SizedBox(height: 14),

                            // Artisan hint
                            if (_isArtisan)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.infoLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, size: 18, color: AppColors.info),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'بعد التسجيل ستتمكن من إكمال ملفك كحرفي',
                                        style: TextStyle(fontSize: 12, color: AppColors.infoText),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Error
                            if (authState.error != null)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.errorBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(authState.error!, style: const TextStyle(color: AppColors.errorText, fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 20),
                            PrimaryButton(
                              text: _isArtisan ? 'التسجيل كحرفي' : 'إنشاء الحساب',
                              isLoading: authState.isLoading,
                              onPressed: _handleRegister,
                            ),
                            const SizedBox(height: 16),

                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('عندك حساب؟', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                                  TextButton(
                                    onPressed: () => context.go('/login'),
                                    child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).register(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      password: _passwordController.text,
      isArtisan: _isArtisan,
    );
  }

  Widget _roleToggle(String label, bool active, bool artisanMode) {
    return GestureDetector(
      onTap: () => setState(() => _isArtisan = artisanMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              artisanMode ? Icons.handyman_rounded : Icons.person_rounded,
              size: 16,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
