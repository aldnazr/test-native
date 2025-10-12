import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapDistance extends StatefulWidget {
  const MapDistance({super.key});

  @override
  State<MapDistance> createState() => _MapDistanceState();
}

class _MapDistanceState extends State<MapDistance> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  LatLng? _firstMarker;
  LatLng? _secondMarker;
  double? _distance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hitung Jarak Antar Pin')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-6.200000, 106.816666), // Jakarta
              zoom: 10,
            ),
            markers: _markers,
            onMapCreated: (controller) => mapController = controller,
            onTap: _handleTap,
          ),
          if (_distance != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Text(
                  'Jarak: ${_distance!.toStringAsFixed(2)} km',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleTap(LatLng tappedPoint) {
    setState(() {
      if (_firstMarker == null) {
        _firstMarker = tappedPoint;
        _markers.add(
          Marker(
            markerId: const MarkerId('first'),
            position: tappedPoint,
            infoWindow: const InfoWindow(title: 'Titik 1'),
          ),
        );
      } else if (_secondMarker == null) {
        _secondMarker = tappedPoint;
        _markers.add(
          Marker(
            markerId: const MarkerId('second'),
            position: tappedPoint,
            infoWindow: const InfoWindow(title: 'Titik 2'),
          ),
        );
        _calculateDistance();
      } else {
        // Reset jika user tap ketiga kali
        _markers.clear();
        _firstMarker = tappedPoint;
        _secondMarker = null;
        _distance = null;
        _markers.add(
          Marker(
            markerId: const MarkerId('first'),
            position: tappedPoint,
            infoWindow: const InfoWindow(title: 'Titik 1'),
          ),
        );
      }
    });
  }

  void _calculateDistance() {
    if (_firstMarker != null && _secondMarker != null) {
      final double distanceInMeters = Geolocator.distanceBetween(
        _firstMarker!.latitude,
        _firstMarker!.longitude,
        _secondMarker!.latitude,
        _secondMarker!.longitude,
      );
      setState(() {
        _distance = distanceInMeters / 1000; // konversi ke km
      });
    }
  }
}
