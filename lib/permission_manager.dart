import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  // Fungsi untuk meminta izin kamera
  static Future<bool> requestCameraPermission() async {
    // 1. Cek status izin saat ini
    var status = await Permission.camera.status;

    // 2. Jika izin belum diberikan, minta kepada pengguna
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    // 3. Tangani hasil permintaan
    if (status.isGranted) {
      // Izin Diberikan
      return true;
    } else if (status.isPermanentlyDenied) {
      // Izin Ditolak secara permanen (Pengguna harus mengaktifkannya di Pengaturan)
      // Anda dapat mengarahkan pengguna ke halaman pengaturan aplikasi
      await openAppSettings();
      return false;
    } else {
      // Izin Ditolak
      return false;
    }
  }

  // Fungsi untuk meminta izin lokasi (contoh lain)
  static Future<bool> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }
}
