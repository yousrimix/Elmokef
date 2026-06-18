import 'dart:io' show Platform;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';

final secureStorageProvider = Provider<FlutterSecureStorage?>((ref) {
  if (kIsWeb) return null;
  try {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      return const FlutterSecureStorage();
    }
  } catch (_) {}
  return null;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(secureStorage: ref.watch(secureStorageProvider));
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(ref.watch(connectivityProvider));
});

final unreadCountProvider = StateProvider<int>((ref) => 0);
