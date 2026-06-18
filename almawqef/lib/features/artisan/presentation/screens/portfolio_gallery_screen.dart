import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class PortfolioGalleryScreen extends StatefulWidget {
  const PortfolioGalleryScreen({super.key});

  @override
  State<PortfolioGalleryScreen> createState() => _PortfolioGalleryScreenState();
}

class _PortfolioGalleryScreenState extends State<PortfolioGalleryScreen> {
  final List<File> _images = [];
  final List<String> _descriptions = [];

  void _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1080, maxHeight: 1080, imageQuality: 85);
    if (xFile != null) {
      setState(() => _images.add(File(xFile.path)));
      _descriptions.add('');
    }
  }

  void _deleteImage(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الصورة'),
        content: const Text('هل تريد حذف هذه الصورة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              setState(() {
                _images.removeAt(index);
                _descriptions.removeAt(index);
              });
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _viewImage(int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            InteractiveViewer(
              maxScale: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _images[index],
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.7,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8, left: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
            Positioned(
              bottom: 16, right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _deleteImage(index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('معرض الأعمال'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded),
            onPressed: _pickImage,
            tooltip: 'إضافة صورة',
          ),
        ],
      ),
      body: _images.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.bgMuted,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.photo_library_outlined, size: 50, color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 20),
                    const Text('لا توجد صور بعد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    const Text('أضف صور أعمالك لترفع فرصك في الظهور\nوتجذب المزيد من الزبائن',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('أضف أول صورة', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  color: AppColors.bg,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${_images.length} صور',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('إضافة', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Gallery
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: _images.length + 1, // +1 for add button
                    itemBuilder: (_, i) {
                      if (i == _images.length) {
                        // Add more button
                        return GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.bgMuted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border, style: BorderStyle.solid, width: 1.5),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded, size: 28, color: AppColors.textTertiary),
                                SizedBox(height: 2),
                                Text('إضافة', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                              ],
                            ),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () => _viewImage(i),
                        onLongPress: () => _deleteImage(i),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_images[i], fit: BoxFit.cover),
                              Positioned(
                                top: 4, right: 4,
                                child: GestureDetector(
                                  onTap: () => _deleteImage(i),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
