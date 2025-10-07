import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImage; // Untuk menyimpan gambar yang diambil

  @override
  void initState() {
    super.initState();
    // Untuk menampilkan output saat ini dari kamera, Anda perlu membuat CameraController.
    _controller = CameraController(
      // Pilih kamera dari daftar yang tersedia.
      widget.camera,
      // Tentukan resolusi yang akan digunakan.
      ResolutionPreset.medium,
    );

    // Berikutnya, inisialisasi controller. Ini mengembalikan Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Buang controller saat Widget dibuang.
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    // Pastikan controller sudah diinisialisasi sebelum mengambil gambar.
    try {
      await _initializeControllerFuture;

      // Ambil gambar dan simpan sebagai XFile.
      final XFile image = await _controller.takePicture();

      // Perbarui state untuk menampilkan gambar.
      setState(() {
        _capturedImage = image;
      });

      // Anda bisa menambahkan navigasi ke layar tampilan gambar di sini.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar diambil dan disimpan di: ${image.path}')),
      );
    } catch (e) {
      // Jika terjadi error, log ke konsol.
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan FutureBuilder untuk menunggu controller selesai diinisialisasi.
    return Scaffold(
      appBar: AppBar(title: const Text('Akses Kamera Android')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Jika Future selesai, tampilkan preview.
            return Stack(
              children: <Widget>[
                // 1. Camera Preview
                Center(child: CameraPreview(_controller)),
                
                // 2. Overlay Gambar yang Diambil (Opsional)
                if (_capturedImage != null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Text(
                          'Gambar Diambil!',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else {
            // Tampilkan spinner loading sampai controller diinisialisasi.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}