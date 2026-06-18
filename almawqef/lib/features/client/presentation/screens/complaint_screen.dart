import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ComplaintScreen extends StatefulWidget {
  final String artisanId;
  final String artisanName;
  const ComplaintScreen({super.key, required this.artisanId, this.artisanName = ''});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  String _selectedSubject = 'خدمة غير مكتملة';
  final _descriptionController = TextEditingController();
  File? _attachment;
  bool _submitted = false;

  final List<_SubjectOption> _subjects = [
    _SubjectOption(Icons.hourglass_empty_rounded, 'خدمة غير مكتملة', AppColors.accent),
    _SubjectOption(Icons.schedule_rounded, 'تأخير في الموعد', const Color(0xFFF97316)),
    _SubjectOption(Icons.monetization_on_outlined, 'سعر غير متفق عليه', AppColors.danger),
    _SubjectOption(Icons.thumb_down_rounded, 'سلوك غير لائق', const Color(0xFFEF4444)),
    _SubjectOption(Icons.gavel_rounded, 'احتيال', const Color(0xFFDC2626)),
    _SubjectOption(Icons.more_horiz_rounded, 'أخرى', AppColors.textSecondary),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _pickAttachment() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (xFile != null) setState(() => _attachment = File(xFile.path));
  }

  bool get _isValid =>
      _selectedSubject.isNotEmpty && _descriptionController.text.trim().length >= 10;

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildSuccess();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('تقديم شكوى'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield_rounded, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('شكواك محمية', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF92400E))),
                      SizedBox(height: 2),
                      Text('سيتم مراجعة شكواك من قبل فريق الدعم خلال 24 ساعة مع الحفاظ على سرية معلوماتك',
                          style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Artisan info
          if (widget.artisanName.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_rounded, size: 24, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الشكوى ضد', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                        Text(widget.artisanName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (widget.artisanName.isNotEmpty) const SizedBox(height: 24),

          // Subject selection
          const Text('سبب الشكوى', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ..._subjects.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _subjectOption(s, _selectedSubject == s.label),
          )),

          const SizedBox(height: 20),

          // Description
          const Text('شرح المشكلة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _descriptionController.text.trim().length >= 10 ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
            ),
            child: TextField(
              controller: _descriptionController,
              maxLines: 5,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'اكتب تفاصيل المشكلة... (10 أحرف على الأقل)',
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_descriptionController.text.trim().isNotEmpty && _descriptionController.text.trim().length < 10)
            const Padding(
              padding: EdgeInsets.only(top: 6, right: 4),
              child: Text('أقل من 10 أحرف، يرجى التوضيح أكثر', style: TextStyle(fontSize: 12, color: AppColors.danger)),
            ),

          const SizedBox(height: 24),

          // Attachment
          Row(
            children: [
              const Text('مرفقات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(width: 6),
              const Text('(اختياري)', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickAttachment,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: _attachment != null ? 140 : 100,
              decoration: BoxDecoration(
                border: Border.all(color: _attachment != null ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border, width: _attachment != null ? 1.5 : 1),
                borderRadius: BorderRadius.circular(14),
                color: _attachment != null ? AppColors.primaryLighter : AppColors.bgMuted,
              ),
              child: _attachment != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.file(_attachment!, width: double.infinity, height: 140, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 8, right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _attachment = null),
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_photo_alternate_outlined, size: 22, color: AppColors.primary),
                        ),
                        const SizedBox(height: 6),
                        const Text('إرفاق صورة', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 32),

          // Submit
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton.icon(
              onPressed: _isValid ? () => setState(() => _submitted = true) : null,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('إرسال الشكوى', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                disabledForegroundColor: AppColors.textTertiary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _subjectOption(_SubjectOption option, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSubject = option.label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? option.color.withValues(alpha: 0.08) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? option.color.withValues(alpha: 0.4) : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: selected ? option.color.withValues(alpha: 0.15) : AppColors.bgMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(option.icon, size: 20, color: selected ? option.color : AppColors.textTertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(option.label,
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500,
                  color: selected ? option.color : AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(color: option.color, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success animation
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF0D9488)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 32),
                const Text('تم استلام شكواك', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Text(
                  'سيتم مراجعتها من قبل فريق الدعم\nسنخطرك بنتيجة المراجعة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.6),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: AppColors.accent),
                      SizedBox(width: 6),
                      Text('الرد خلال 24 ساعة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF92400E))),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('العودة للرئيسية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectOption {
  final IconData icon;
  final String label;
  final Color color;
  const _SubjectOption(this.icon, this.label, this.color);
}
