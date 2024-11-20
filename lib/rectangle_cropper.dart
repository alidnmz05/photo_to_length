import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RectangleSelectorWithGallery extends StatefulWidget {
  @override
  _RectangleSelectorWithGalleryState createState() =>
      _RectangleSelectorWithGalleryState();
}

class _RectangleSelectorWithGalleryState
    extends State<RectangleSelectorWithGallery> {
  File? _selectedImage;

  // Dikdörtgen seçim alanının başlangıç ve boyut değerleri
  double top = 100;
  double left = 50;
  double width = 200;
  double height = 150;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Galeriden Dikdörtgen Seçimi"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_selectedImage != null) {
                // Dikdörtgen alanının boyutlarını ekrana yazdır
                print("Top: $top, Left: $left, Width: $width, Height: $height");
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Seçim Boyutları"),
                    content: Text(
                        "Top: $top\nLeft: $left\nWidth: $width\nHeight: $height"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Tamam"),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _selectedImage == null
          ? Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: Text("Galeriden Fotoğraf Seç"),
              ),
            )
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(16.0),
                      color: Colors.grey[300],
                      width: MediaQuery.of(context).size.width *
                          0.9, // Fotoğrafın ekran genişliğine göre boyutu
                      height: MediaQuery.of(context).size.height *
                          0.6, // Fotoğrafın yüksekliği
                      child: Stack(
                        children: [
                          // Seçilen fotoğrafı ekrana sığdır
                          Positioned.fill(
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.contain, // Ekrana göre boyutlandır
                            ),
                          ),

                          // Dikdörtgen seçim alanı
                          Positioned(
                            top: top,
                            left: left,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                // Dikdörtgenin sürüklenmesi
                                setState(() {
                                  top += details.delta.dy;
                                  left += details.delta.dx;
                                });
                              },
                              child: Container(
                                width: width,
                                height: height,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.red, width: 2),
                                  color: Colors.red.withOpacity(0.2),
                                ),
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    // Dikdörtgenin boyutlarının ayarlanması
                                    setState(() {
                                      width += details.delta.dx;
                                      height += details.delta.dy;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
