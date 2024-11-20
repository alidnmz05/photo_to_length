import 'package:flutter/material.dart';
import 'dart:io';
import 'package:photo_to_length/screens/focus_thirst.dart';

class FocusSecond extends StatefulWidget {
  final File? image;
  FocusSecond({required this.image});

  @override
  _FocusSecondState createState() => _FocusSecondState();
}

class _FocusSecondState extends State<FocusSecond> {
  double scale = 1.0;
  Offset offset = Offset.zero;
  double top = 100;
  double left = 50;
  double width = 85;
  double height = 54;
  String? selectedReference = 'Kart/Kimlik';

  void moveImage(double dx) {
    setState(() {
      offset += Offset(dx, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Referans Objeyi Seç"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: selectedReference,
            hint: const Text(
              'Bir Seçim Yapın',
              style: TextStyle(fontSize: 18), // Yazı tipi boyutu büyütüldü
            ),
            isExpanded: true, // Dropdown'un tam genişlikte olmasını sağlar
            icon: Icon(Icons.arrow_drop_down, size: 36), // İkon boyutunu artır
            iconSize: 36, // İkonun boyutunu artır
            elevation: 16,
            style: TextStyle(
                fontSize: 18, color: Colors.black), // Yazı boyutunu artır
            onChanged: (String? newValue) {
              setState(() {
                selectedReference = newValue;
              });
            },
            items: const [
              DropdownMenuItem<String>(
                value: 'A4 Kağıt',
                child: Row(
                  children: [
                    Icon(Icons.document_scanner,
                        color: Colors.blue, size: 24), // İkon boyutunu artır
                    SizedBox(width: 15),
                    Text('A4 Kağıt',
                        style: TextStyle(fontSize: 18)), // Yazı boyutunu artır
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: 'Kart/Kimlik',
                child: Row(
                  children: [
                    Icon(Icons.credit_card,
                        color: Colors.green, size: 24), // İkon boyutunu artır
                    SizedBox(width: 15),
                    Text('Kart/Kimlik',
                        style: TextStyle(fontSize: 18)), // Yazı boyutunu artır
                  ],
                ),
              ),
            ],
          ),

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
          // Display image and interactive area
          Expanded(
            child: Center(
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    // Fotoğraf yoksa yazıyı göster
                    if (widget.image == null)
                      Center(
                        child: Text(
                          'Fotoğraf Yükleyin',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    // Resim gösterimi
                    if (widget.image != null) ...[
                      Transform(
                        transform: Matrix4.identity()
                          ..scale(scale)
                          ..translate(offset.dx, offset.dy),
                        child: Image.file(
                          widget.image!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                    // Noktalar ve interaktif daireler
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
                            border: Border.all(
                                color: Colors.grey,
                                width: 1.5), // İnce kenarlık
                            color: Colors.grey
                                .withOpacity(0.1), // Daha hafif arka plan
                          ),
                          child: Stack(
                            children: [
                              // Sağ alt köşe tutamağı
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    // Dikdörtgenin boyutlarının ayarlanması
                                    setState(() {
                                      width = (width + details.delta.dx).clamp(
                                          20, double.infinity); // Min. genişlik
                                      height = (height + details.delta.dy)
                                          .clamp(
                                              20,
                                              double
                                                  .infinity); // Min. yükseklik
                                    });
                                  },
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape
                                          .circle, // Daha modern bir köşe
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.check,
                    size: 40,
                    color:
                        selectedReference == null ? Colors.grey : Colors.green,
                  ),
                  onPressed: selectedReference == null
                      ? null
                      : () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FocusThirst(
                                  image: widget.image,
                                  width: width,
                                  heigth: height,
                                  selectedReference: selectedReference,
                                ),
                              ));
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
