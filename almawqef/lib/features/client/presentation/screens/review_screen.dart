import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String artisanId;
  final String artisanName;

  const ReviewScreen({
    super.key,
    required this.artisanId,
    required this.artisanName,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> with SingleTickerProviderStateMixin {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitted = false;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  final List<String> _starLabels = ['ضعيف', 'مقبول', 'جيد', 'ممتاز', 'رائع!'];
  final List<String> _starEmojis = ['😞', '😐', '🙂', '😊', '🔥'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(
        ApiConstants.reviews,
        data: {
          'artisan_id': widget.artisanId,
          'rating': _rating,
          'comment': _commentController.text.trim(),
        },
      );

      if (!mounted) return;
      setState(() {
        _submitted = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء إرسال التقييم. حاول مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildSuccess();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('تقييم'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Artisan avatar
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF0D9488)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.person_rounded, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(widget.artisanName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 32),

            // Question
            const Text('كيف كانت الخدمة مع هذا الحرفي؟',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 24),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final filled = index < _rating;
                return GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
                          setState(() => _rating = index + 1);
                          _animController.forward(from: 0);
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedScale(
                      scale: filled ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        filled ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 52,
                        color: filled ? AppColors.starActive : AppColors.starInactive,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),

            // Rating label + emoji
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _rating > 0
                  ? Row(
                      key: ValueKey(_rating),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_starEmojis[_rating - 1], style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          _starLabels[_rating - 1],
                          style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600,
                            color: [AppColors.danger, AppColors.accent, AppColors.info, AppColors.primary, const Color(0xFF059669)][_rating - 1],
                          ),
                        ),
                      ],
                    )
                  : const Text('اضغط على نجمة للتقييم',
                      style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
            ),

            const SizedBox(height: 32),

            // Comment
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: 3,
                textDirection: TextDirection.rtl,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'شارك تجربتك مع هذا الحرفي...',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!,
                          style: const TextStyle(fontSize: 13, color: AppColors.danger)),
                    ),
                  ],
                ),
              ),

            SizedBox(height: _errorMessage != null ? 8 : 16),

            // Submit
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _rating > 0 && !_isLoading ? _submitReview : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _isLoading
                      ? 'جاري الإرسال...'
                      : _rating > 0
                          ? 'إرسال التقييم'
                          : 'اختر تقييماً أولاً',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
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

            const SizedBox(height: 16),
            const Text('تقييمك يساعد الآخرين في اختيار الحرفي المناسب',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary), textAlign: TextAlign.center),

            const SizedBox(height: 40),
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
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF0D9488)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 28),
                const Text('شكراً لتقييمك!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(widget.artisanName, style: const TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('تقييمك ساعد 3 عملاء اليوم', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('العودة للرئيسية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('قيّم حرفياً آخر', style: TextStyle(fontSize: 15, color: AppColors.primary)),
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
