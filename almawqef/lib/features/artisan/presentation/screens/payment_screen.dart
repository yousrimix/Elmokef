import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class PaymentScreen extends StatefulWidget {
  final String planId;
  const PaymentScreen({super.key, required this.planId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _useFallback = false;
  int? _paymentId;
  WebSocketChannel? _wsChannel;
  bool _confirmed = false;
  bool _failed = false;
  late String _cmiUrl;

  String _getPlanName() {
    switch (widget.planId) {
      case 'pro': return 'احترافي';
      case 'premium': return 'مميز';
      default: return 'مجاني';
    }
  }

  String _getAmount() {
    switch (widget.planId) {
      case 'pro': return '99';
      case 'premium': return '199';
      default: return '0';
    }
  }

  @override
  void initState() {
    super.initState();
    _paymentId = DateTime.now().millisecondsSinceEpoch;
    _cmiUrl = 'https://pay.cmi.co.ma/pay?merchant=elmokef&amount=${_getAmount()}&currency=MAD&plan=${_getPlanName()}';

    if (kIsWeb || defaultTargetPlatform == TargetPlatform.iOS) {
      _useFallback = true;
      _openInSafari();
    } else {
      _initWebView();
    }
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => _updateLoading(true),
        onPageFinished: (_) => _updateLoading(false),
        onNavigationRequest: (request) {
          if (request.url.contains('api.elmokef.ma/payments/success')) {
            _onPaymentSuccess();
            return NavigationDecision.prevent;
          }
          if (request.url.contains('api.elmokef.ma/payments/failure')) {
            _onPaymentFailure();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onWebResourceError: (_) {
          _updateLoading(false);
          _showFallbackOption();
        },
      ))
      ..loadRequest(Uri.parse(_cmiUrl));
  }

  void _updateLoading(bool loading) {
    if (mounted) setState(() => _isLoading = loading);
  }

  void _showFallbackOption() {
    if (mounted) setState(() => _useFallback = true);
  }

  void _openInSafari() async {
    final uri = Uri.parse(_cmiUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    _connectWebSocket();
  }

  void _onPaymentSuccess() {
    setState(() => _confirmed = true);
    _connectWebSocket();
  }

  void _onPaymentFailure() {
    _wsChannel?.sink.close();
    setState(() => _failed = true);
  }

  void _connectWebSocket() {
    try {
      _wsChannel = WebSocketChannel.connect(
        Uri.parse('wss://api.elmokef.ma/ws/payments?paymentId=$_paymentId'),
      );
      _wsChannel!.stream.listen(
        (data) {
          final msg = data.toString();
          if (msg.contains('payment:confirmed:$_paymentId')) {
            if (mounted) {
              _wsChannel?.sink.close();
              setState(() => _confirmed = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تفعيل اشتراكك في الباقة ${_getPlanName()} 🎉'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          }
        },
        onError: (_) {},
        onDone: () {},
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _wsChannel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmed) return _buildSuccess();
    if (_failed) return _buildFailure();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('الدفع'),
        centerTitle: true,
        actions: [
          if (_useFallback)
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              tooltip: 'فتح في المتصفح',
              onPressed: _openInSafari,
            ),
        ],
      ),
      body: _useFallback ? _buildFallbackView() : _buildWebView(),
    );
  }

  Widget _buildWebView() {
    if (_controller == null) return const SizedBox();
    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        if (_isLoading)
          Positioned(
            top: 0, left: 0, right: 0,
            child: LinearProgressIndicator(
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: AppColors.bg.withValues(alpha: 0.7),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.payment_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 28),
            const Text('صفحة الدفع', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('سيتم فتح صفحة الدفع الآمن في المتصفح\nبرجاء العودة إلى التطبيق بعد إتمام الدفع',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.6), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('المبلغ: ${_getAmount()} درهم', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(width: 6),
                  Text('— الباقة ${_getPlanName()}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _openInSafari,
                icon: const Icon(Icons.language_rounded, size: 20),
                label: const Text('فتح صفحة الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/subscriptions'),
              child: const Text('العودة للباقات', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
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
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF0D9488)]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.check_rounded, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 28),
                const Text('🎉 تهانينا!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text('تم تفعيل اشتراكك في الباقة ${_getPlanName()}',
                    style: const TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('استمتع بالمميزات الجديدة!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/artisan-dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('العودة للوحة التحكم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailure() {
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
                    color: AppColors.dangerLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 56, color: AppColors.danger),
                ),
                const SizedBox(height: 28),
                const Text('فشلت عملية الدفع', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('يرجى المحاولة مرة أخرى\nأو استخدام بطاقة أخرى',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _failed = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('إعادة المحاولة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/subscriptions'),
                  child: const Text('العودة للباقات', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
