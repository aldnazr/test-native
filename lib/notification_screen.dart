import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  String _fcmToken = 'Memuat Token...';

  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  void _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    // 1. Minta Izin Notifikasi (Hanya Wajib di iOS, tapi praktik bagus)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Izin Notifikasi: ${settings.authorizationStatus}');
    
    // 2. Dapatkan FCM Token
    String? token = await messaging.getToken();
    setState(() {
      _fcmToken = token ?? 'Gagal mendapatkan token';
    });
    
    // PENTING: Simpan token ini di database server Anda untuk mengirim notifikasi
    print("FCM Token: $token");

    // 3. Tangani Pesan Saat Aplikasi di Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Pesan diterima saat di Foreground!');
      print('Data: ${message.data}');
      
      // Tampilkan notifikasi lokal di sini (memerlukan package flutter_local_notifications)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Notifikasi Baru: ${message.notification?.title}"),
          backgroundColor: Colors.blueGrey,
        ),
      );
    });

    // 4. Tangani Pesan Saat Aplikasi Dibuka dari Notifikasi (Terminated/Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Aplikasi dibuka dari Notifikasi!');
      // Arahkan pengguna ke layar tertentu berdasarkan message.data
      Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(data: message.data)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FCM Notifikasi')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('FCM Token Anda:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              SelectableText(
                _fcmToken,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Gunakan token di atas untuk mengirim notifikasi dari Firebase Console atau server Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// --- Contoh Layar Detail ---
class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Notifikasi')),
      body: Center(
        child: Text('Data yang diterima: \n$data'),
      ),
    );
  }
}