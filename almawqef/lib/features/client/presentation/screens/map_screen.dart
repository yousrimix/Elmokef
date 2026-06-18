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
  bool _locationLoading = true;
  int? _selectedArtisanId;

  final List<_ArtisanMarker> _mockArtisans = [
    _ArtisanMarker(1, 'أحمد العلوي', 33.5731, -7.5898, 4.8, 'سباك', '150-300', null),
    _ArtisanMarker(2, 'محمد الصقلي', 33.5780, -7.5950, 4.5, 'كهربائي', '120-250', null),
    _ArtisanMarker(3, 'فاطمة بنعلي', 33.5700, -7.5850, 4.9, 'صبّاغة', '200-400', null),
    _ArtisanMarker(4, 'خالد العمري', 33.5760, -7.6000, 4.3, 'نجّار', '300-600', null),
    _ArtisanMarker(5, 'سعيد المنصوري', 33.5690, -7.5920, 4.7, 'حدّاد', '150-350', null),
  ];

  static const LatLng _defaultCenter = LatLng(33.5731, -7.5898); // Casa

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationLoading = false);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
        _locationLoading = false;
      });
    } catch (_) {
      setState(() => _locationLoading = false);
    }
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
                markers: _mockArtisans.map((a) => Marker(
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
                    child: Text('${_mockArtisans.length} حرفي', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_locationLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
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
    final a = _mockArtisans.firstWhere((a) => a.id == _selectedArtisanId);
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
                          if (a.id == 1)
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
                  child: Text(a.price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
                const Spacer(),
                SizedBox(
                  width: 140, height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/artisan/art-uuid-00${a.id}'),
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
  final String price;
  final String? image;
  const _ArtisanMarker(this.id, this.name, this.lat, this.lng, this.rating, this.profession, this.price, this.image);
}
