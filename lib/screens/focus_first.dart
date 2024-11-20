import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:photo_to_length/screens/focus_second.dart';

class FocusFirst extends StatefulWidget {
  @override
  _FocusFirstState createState() => _FocusFirstState();
}

class _FocusFirstState extends State<FocusFirst> {
  File? _image;
  double scale = 1.0;
  Offset offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.photos].request();
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void moveImage(double dx) {
    setState(() {
      offset += Offset(dx, 0);
    });
  }

  // Function to convert px to cm
  double pxToCm(double px) {
    double dpi = MediaQuery.of(context).devicePixelRatio *
        160; // 160 is the baseline density for mdpi
    double inches = px / dpi;
    double cm = inches * 60;
    return cm;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Fotoğraf Yükle"),
      ),
      body: Column(
        children: [
          // Zoom and Move buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: () {
                  moveImage(-20); // Move left
                },
              ),
              IconButton(
                icon: Icon(Icons.zoom_out),
                onPressed: () {
                  setState(() {
                    scale = (scale - 0.1).clamp(1.0, double.infinity);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.zoom_in),
                onPressed: () {
                  setState(() {
                    scale += 0.1;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: () {
                  moveImage(20); // Move right
                },
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    // Fotoğraf yoksa yazıyı göster
                    if (_image == null)
                      Center(
                        child: Text(
                          'Fotoğraf Yükleyin',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    // Resim gösterimi
                    if (_image != null) ...[
                      Transform(
                        transform: Matrix4.identity()
                          ..scale(scale)
                          ..translate(offset.dx, offset.dy),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                    // Noktalar ve interaktif daireler
                  ],
                ),
              ),
            ),
          ),
          // Image picker buttons
          SizedBox(width: 130),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.camera_alt, size: 40),
                  onPressed: _pickImageFromCamera,
                ),
                SizedBox(
                  width: 50,
                ),
                IconButton(
                  icon: Icon(Icons.photo_library, size: 40),
                  onPressed: _pickImageFromGallery,
                ),
                SizedBox(
                  width: 50,
                ),
                IconButton(
                  icon: Icon(
                    Icons.check,
                    size: 40,
                    color: _image == null ? Colors.grey : Colors.green,
                  ),
                  onPressed: _image == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FocusSecond(
                                image: _image,
                              ),
                            ),
                          );
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
