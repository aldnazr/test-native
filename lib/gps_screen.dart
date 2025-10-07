import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GpsAccessService {
  // 1. Cek Layanan Lokasi (GPS dihidupkan atau tidak)
  static Future<bool> _isLocationServiceEnabled() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      // Jika GPS mati, tampilkan pesan dan mungkin buka pengaturan lokasi.
      return false;
    }
    return true;
  }

  // 2. Cek dan Minta Izin (Runtime Permission)
  static Future<LocationPermission> _checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Minta izin dari pengguna
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Izin ditolak (tapi belum permanen)
        return Future.error('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Izin ditolak secara permanen. Arahkan ke pengaturan.
      await openAppSettings();
      return Future.error(
        'Izin lokasi ditolak permanen. Silakan ubah di Pengaturan.',
      );
    }

    return permission;
  }

  // 3. Ambil Lokasi Saat Ini
  static Future<Position> getCurrentLocation() async {
    try {
      // Step 1: Cek apakah GPS aktif
      if (!await _isLocationServiceEnabled()) {
        throw Exception("Layanan GPS tidak aktif.");
      }

      // Step 2: Cek dan minta izin
      LocationPermission permission = await _checkAndRequestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Jika izin belum granted, lemparkan error dari _checkAndRequestPermission
        throw Exception("Izin lokasi tidak diberikan.");
      }

      // Step 3: Dapatkan posisi
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      // Melemparkan kembali error untuk ditangani di UI
      throw Exception('Gagal mendapatkan lokasi: ${e.toString()}');
    }
  }
}

// --- Contoh Penggunaan di UI ---

class GpsScreen extends StatelessWidget {
  const GpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akses GPS/Lokasi')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              Position position = await GpsAccessService.getCurrentLocation();

              String message =
                  'Lat: ${position.latitude.toStringAsFixed(4)}\n'
                  'Lon: ${position.longitude.toStringAsFixed(4)}';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Lokasi Berhasil Diambil: \n$message',
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 5),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceFirst('Exception: ', '')),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
          child: const Text('Dapatkan Lokasi Saya (GPS)'),
        ),
      ),
    );
  }
}
