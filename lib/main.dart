import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-Time Location Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Map controller
  GoogleMapController? _mapController;

  // Current and previous location
  LatLng? _currentLatLng;
  LatLng? _previousLatLng;

  // Marker set
  final Set<Marker> _markers = {};

  // Polyline set
  final Set<Polyline> _polylines = {};

  // List of all visited points for the polyline
  final List<LatLng> _polylinePoints = [];

  // Timer for periodic location updates
  Timer? _locationTimer;

  // Whether we have done the initial animation
  bool _initialAnimationDone = false;

  // Loading state
  bool _isLoading = true;

  // Status message
  String _statusMessage = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ─── Permission & initial location ───────────────────────────────────────

  Future<void> _initLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled. Please enable GPS.');
      return;
    }

    // Request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError(
        'Location permissions are permanently denied. '
        'Please enable them in app settings.',
      );
      return;
    }

    // Fetch the first location immediately
    await _fetchAndUpdateLocation();

    // Start the 10-second periodic timer
    _locationTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchAndUpdateLocation(),
    );
  }

  // ─── Fetch location & update map ─────────────────────────────────────────

  Future<void> _fetchAndUpdateLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final LatLng newLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _previousLatLng = _currentLatLng;
        _currentLatLng = newLatLng;
        _isLoading = false;
        _statusMessage =
            'Updated: ${_fmt(position.latitude)}, ${_fmt(position.longitude)}';

        // Add point to polyline history
        _polylinePoints.add(newLatLng);

        // Update marker
        _updateMarker(newLatLng, position.latitude, position.longitude);

        // Update polyline
        if (_polylinePoints.length >= 2) {
          _updatePolyline();
        }
      });

      // Animate camera to the new location
      if (!_initialAnimationDone) {
        _initialAnimationDone = true;
        await _animateCameraTo(newLatLng, zoom: 16.0);
      } else {
        await _animateCameraTo(newLatLng, zoom: 16.0);
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
    }
  }

  // ─── Marker ───────────────────────────────────────────────────────────────

  void _updateMarker(LatLng position, double lat, double lng) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: position,
        infoWindow: InfoWindow(
          title: 'My current location',
          snippet: '${_fmt(lat)}, ${_fmt(lng)}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  // ─── Polyline ─────────────────────────────────────────────────────────────

  void _updatePolyline() {
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('location_path'),
        points: List<LatLng>.from(_polylinePoints),
        color: const Color(0xFF1A73E8),
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    );
  }

  // ─── Camera animation ─────────────────────────────────────────────────────

  Future<void> _animateCameraTo(LatLng target, {double zoom = 16.0}) async {
    if (_mapController == null) return;
    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _fmt(double value) => value.toStringAsFixed(6);

  void _showError(String message) {
    setState(() {
      _isLoading = false;
      _statusMessage = message;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              // Start at a generic world view; will animate to real position
              target: LatLng(23.8103, 90.4125), // Dhaka as default
              zoom: 5,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapType: MapType.normal,
          ),

          // ── Top App Bar ─────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1A73E8).withOpacity(0.95),
                    const Color(0xFF1A73E8).withOpacity(0.0),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF1A73E8),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Real-Time Location Tracker',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'Updates every 10 seconds',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
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

          // ── Loading Overlay ─────────────────────────────────────────────
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.45),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Fetching your location...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Bottom Status Card ──────────────────────────────────────────
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _buildStatusCard(),
          ),

          // ── My Location FAB ─────────────────────────────────────────────
          Positioned(
            bottom: 130,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'my_location',
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                if (_currentLatLng != null) {
                  _animateCameraTo(_currentLatLng!, zoom: 16.0);
                }
              },
              child: const Icon(
                Icons.my_location,
                color: Color(0xFF1A73E8),
              ),
            ),
          ),

          // ── Refresh FAB ─────────────────────────────────────────────────
          Positioned(
            bottom: 210,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'refresh',
              backgroundColor: const Color(0xFF1A73E8),
              elevation: 4,
              onPressed: _fetchAndUpdateLocation,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Status Card Widget ────────────────────────────────────────────────────

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentLatLng != null
                      ? Colors.green
                      : Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _currentLatLng != null ? 'Location Active' : 'Locating...',
                style: TextStyle(
                  color: _currentLatLng != null
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (_polylinePoints.length >= 2)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timeline,
                        size: 13,
                        color: Color(0xFF1A73E8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_polylinePoints.length} points',
                        style: const TextStyle(
                          color: Color(0xFF1A73E8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (_currentLatLng != null) ...[
            const Divider(height: 16),
            Row(
              children: [
                _infoChip(
                  icon: Icons.south,
                  label: 'Lat',
                  value: _fmt(_currentLatLng!.latitude),
                ),
                const SizedBox(width: 12),
                _infoChip(
                  icon: Icons.east,
                  label: 'Lng',
                  value: _fmt(_currentLatLng!.longitude),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '⏱ Next update in ~10s  •  Tap marker for info window',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202124),
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
