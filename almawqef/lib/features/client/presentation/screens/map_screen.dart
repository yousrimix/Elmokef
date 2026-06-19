import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/rating_bar.dart';
import '../../../../core/di/providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String serviceName;
  const MapScreen({super.key, required this.serviceId, this.serviceName = ''});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _error;
  int? _selectedArtisanId;

  List<_ArtisanMarker> _artisans = [];

  static const LatLng _defaultCenter = LatLng(33.5731, -7.5898); // Casa

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Fetch artisans from API
    await _fetchArtisans();
    // Then try location
    await _getCurrentLocation();
  }

  Future<void> _fetchArtisans() async {
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get('/api/v1/artisans');
      final data = response.data as Map<String, dynamic>;
      final list = (data['data'] ?? data['artisans'] ?? []) as List;

      final markers = <_ArtisanMarker>[];
      var index = 0;
      for (final item in list) {
        final user = item['user'] as Map<String, dynamic>? ?? {};
        final lat = (item['latitude'] as num?)?.toDouble();
        final lng = (item['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          markers.add(_ArtisanMarker(
            index++,
            user['name'] as String? ?? 'حرفي',
            lat,
            lng,
            (item['ratingAvg'] as num?)?.toDouble() ?? 4.5,
            (item['services'] as List?)?.firstOrNull?['name'] as String? ?? 'خدمات',
            user['image'] as String?,
            item['id'] as String? ?? '',
          ));
        }
      }
      setState(() => _artisans = markers);
    } catch (e) {
      setState(() => _error = 'فشل تحميل البيانات');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = LatLng(pos.latitude, pos.longitude));
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? _defaultCenter,
              initialZoom: 14.0,
              onTap: (_, __) => setState(() => _selectedArtisanId = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.elmokef.app',
              ),
              // User location marker
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 40, height: 40,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              // Artisan markers
              MarkerLayer(
                markers: _artisans.map((a) => Marker(
                  point: LatLng(a.lat, a.lng),
                  width: 80, height: 80,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedArtisanId = a.id),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6)],
                          ),
                          child: Text('${a.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16, right: 16,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12)],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 22),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.map_outlined, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.serviceName.isNotEmpty ? widget.serviceName : 'الخريطة',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${_artisans.length} حرفي', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          if (_error != null)
            Positioned(
              bottom: 100, left: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12)],
                ),
                child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
              ),
            ),

          // Bottom card for selected artisan
          if (_selectedArtisanId != null)
            _buildBottomCard(),
        ],
      ),
    );
  }

  Widget _buildBottomCard() {
    final a = _artisans.firstWhere((a) => a.id == _selectedArtisanId);
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 16,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_rounded, size: 28, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(a.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(width: 6),
                          if (a.rating >= 4.8)
                            Container(
                              width: 18, height: 18,
                              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(a.profession, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.starActive),
                      const SizedBox(width: 3),
                      Text('${a.rating}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${a.rating.toInt()}+', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
                const Spacer(),
                SizedBox(
                  width: 140, height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/artisan/${a.artisanId}'),
                    icon: const Icon(Icons.person_rounded, size: 16),
                    label: const Text('عرض الملف', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtisanMarker {
  final int id;
  final String name;
  final double lat, lng;
  final double rating;
  final String profession;
  final String artisanId;
  final String? image;
  const _ArtisanMarker(this.id, this.name, this.lat, this.lng, this.rating, this.profession, this.image, this.artisanId);
}
