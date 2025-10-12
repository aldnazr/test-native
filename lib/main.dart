import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/counter_screen.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/gps_screen.dart';
import 'package:myapp/map_distance.dart';
import 'package:myapp/notification_screen.dart';
import 'package:myapp/notification_service.dart';
import 'package:myapp/permission_manager.dart';
import 'package:myapp/take_picture_screen.dart';

late List<CameraDescription> cameras;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  // Pastikan bindings Flutter sudah diinisialisasi.
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp();

  // Atur background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Local Notification
  await NotificationService.init();

  // Ambil daftar kamera yang tersedia di perangkat.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    throw Exception(e);
  }
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? title;
  const MyHomePage({super.key, this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Native')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: const Text('Minta Izin Kamera'),
              onPressed: () async {
                bool isGranted =
                    await PermissionManager.requestCameraPermission();

                String message = isGranted
                    ? 'Izin Kamera Berhasil Diberikan! 🎉'
                    : 'Izin Kamera Ditolak. 😔';

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              },
            ),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TakePictureScreen(camera: cameras.first),
                  ),
                );
              },
              child: Text('Kamera'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GpsScreen()),
                );
              },
              child: Text('GPS'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
              child: Text('Firebase Notification'),
            ),
            FilledButton(
              onPressed: () {
                NotificationService.showNotification(
                  id: 0,
                  title: 'Halo!',
                  body: 'Ini adalah notifikasi lokal sederhana.',
                );
              },
              child: const Text('Local Notification'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapDistance()),
                );
              },
              child: Text('Google Maps'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CounterScreen()),
                );
              },
              child: Text('Test Riverpod'),
            ),
          ],
        ),
      ),
    );
  }
}
