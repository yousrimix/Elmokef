import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  int _currentStep = 0;
  final _nameController = TextEditingController(text: 'حرّاث بنعلي');
  final _phoneController = TextEditingController(text: '+212 6XX XX XX XX');
  final _bioController = TextEditingController(text: 'حرفي محترف عندي 12 سنة خبرة في المجال.');

  String _selectedCity = 'فاس';
  File? _profileImage;
  File? _idImage;
  bool _acceptedTerms = false;

  final List<String> _cities = [
    'الدار البيضاء', 'فاس', 'مراكش', 'طنجة', 'أكادير', 'مكناس', 'وجدة', 'القنيطرة', 'تطوان', 'تاوريرت'
  ];

  final List<Map<String, dynamic>> _steps = [
    {'icon': Icons.person_rounded, 'title': 'المعلومات الأساسية'},
    {'icon': Icons.photo_camera_rounded, 'title': 'الصور والهوية'},
    {'icon': Icons.check_circle_rounded, 'title': 'المراجعة'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('إنشاء حساب حرفي'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress stepper
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            color: AppColors.bgCard,
            child: Row(
              children: List.generate(_steps.length, (i) {
                final isActive = i == _currentStep;
                final isDone = i < _currentStep;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                gradient: isActive || isDone
                                    ? AppColors.primaryGradient
                                    : null,
                                color: isActive || isDone ? null : AppColors.border,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isDone ? Icons.check_rounded : _steps[i]['icon'] as IconData,
                                size: 18, color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _steps[i]['title'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                color: isActive ? AppColors.primary : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < _steps.length - 1)
                        Container(
                          height: 2,
                          width: double.infinity,
                          color: isDone ? AppColors.primary : AppColors.border,
                          margin: const EdgeInsets.only(bottom: 20),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Steps content
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: EdgeInsets.only(
              left: 20, right: 20,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: const Text('السابق', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: _currentStep > 0 ? 1 : 0,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _currentStep < 2
                          ? () => setState(() => _currentStep++)
                          : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _currentStep < 2 ? 'التالي' : 'إنشاء الحساب',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Text('المعلومات الأساسية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('هذه المعلومات حتظهر في ملفك الشخصي عند الزبائن',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        // Name
        _inputLabel('الاسم الكامل'),
        const SizedBox(height: 8),
        _buildTextField(_nameController, 'مثلاً: أحمد العلوي', Icons.person_outlined),

        const SizedBox(height: 20),
        _inputLabel('رقم الهاتف'),
        const SizedBox(height: 8),
        _buildTextField(_phoneController, 'مثلاً: +212 6XX XX XX XX', Icons.phone_outlined, keyboardType: TextInputType.phone),

        const SizedBox(height: 20),
        _inputLabel('المدينة'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCity,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCity = v ?? ''),
            ),
          ),
        ),

        const SizedBox(height: 20),
        _inputLabel('نبذة عنك'),
        const SizedBox(height: 8),
        _buildTextField(_bioController, 'اكتب وصف مختصر لخبراتك...', Icons.description_outlined, maxLines: 4),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep2() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Text('الصور والهوية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('أضف صورتك الشخصية ووثيقة هويتك لإكمال التسجيل',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        // Profile image
        _inputLabel('الصورة الشخصية'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage('profile'),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, style: _profileImage != null ? BorderStyle.none : BorderStyle.solid),
            ),
            child: _profileImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(_profileImage!, fit: BoxFit.cover, width: double.infinity),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(height: 8),
                      const Text('اضغط لإضافة صورة', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 24),
        _inputLabel('وثيقة الهوية'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage('id'),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, style: _idImage != null ? BorderStyle.none : BorderStyle.solid),
            ),
            child: _idImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(_idImage!, fit: BoxFit.cover, width: double.infinity),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.badge_outlined, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('البطاقة الوطنية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text('أو جواز السفر', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 24),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStep3() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Text('مراجعة المعلومات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('تأكد من صحة معلوماتك قبل إرسال الطلب',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        // Review card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: _profileImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(21),
                        child: Image.file(_profileImage!, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.person_rounded, size: 38, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(_nameController.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(_phoneController.text, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(_selectedCity, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _idImage != null ? AppColors.successLight : AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_idImage != null ? Icons.check_rounded : Icons.close_rounded, size: 14,
                              color: _idImage != null ? AppColors.success : AppColors.danger),
                          const SizedBox(width: 4),
                          Text(_idImage != null ? 'الهوية مرفوعة' : 'الهوية غير مرفوعة',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                                  color: _idImage != null ? AppColors.success : AppColors.danger)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Terms
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgMuted,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: _acceptedTerms ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _acceptedTerms ? AppColors.primary : AppColors.textTertiary),
                  ),
                  child: _acceptedTerms
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'أوافق على شروط الاستخدام وسياسة الخصوصية وأؤكد أن جميع المعلومات المقدمة صحيحة',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  void _pickImage(String type) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (xFile != null) {
      setState(() {
        if (type == 'profile') _profileImage = File(xFile.path);
        else _idImage = File(xFile.path);
      });
    }
  }

  void _onSubmit() {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى الموافقة على شروط الاستخدام')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('تم إرسال طلبك!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('سيتم مراجعة طلبك من قبل فريق الدعم', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('تم'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(icon, size: 20, color: AppColors.textTertiary),
        ),
      ),
    );
  }
}
