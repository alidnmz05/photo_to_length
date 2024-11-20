import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:math' as math;

class FocusScreen extends StatefulWidget {
  @override
  _FocusScreenState createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  File? _image;
  List<Point> points = [];
  int? selectedPointIndex = 0;
  double scale = 1.0;
  Offset offset = Offset.zero;
  double top = 100;
  double left = 50;
  double width = 200;
  double height = 150;

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

  void handleTapGesture(Offset location) {
    setState(() {
      Offset adjustedLocation = (location - offset) / scale;
      if (points.length < 2) {
        points
            .add(Point(position: adjustedLocation, isSelected: points.isEmpty));
      } else if (selectedPointIndex != null) {
        points[selectedPointIndex!].setPosition = adjustedLocation;
      }
    });
  }

  double distanceBetweenPoints() {
    if (points.length != 2) return 0;
    double dx = points[1].position.dx - points[0].position.dx;
    double dy = points[1].position.dy - points[0].position.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  void selectPoint(Point point) {
    if (selectedPointIndex == 1) {
      selectedPointIndex = 0;
    } else {
      selectedPointIndex = 1;
    }
  }

  void clearSelection() {
    setState(() {
      points.clear();
      selectedPointIndex = null;
    });
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
        title: const Text("Ölçüm Uygulaması"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_image != null) {
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
          // Display image and interactive area
          Expanded(
            child: Center(
              child: GestureDetector(
                onScaleUpdate: (details) {
                  setState(() {
                    scale = details.scale;
                    offset = details.focalPoint - details.localFocalPoint;
                  });
                },
                onTapUp: (details) {
                  handleTapGesture(details.localPosition);
                },
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
                      ...points.map((point) {
                        Offset adjustedPosition =
                            point.position * scale + offset;
                        return Positioned(
                          left: adjustedPosition.dx,
                          top: adjustedPosition.dy,
                          child: GestureDetector(
                            onTap: () {
                              selectPoint(
                                  point); // Nokta seçme fonksiyonunu tetikle
                            },
                            child: CircleAvatar(
                                radius: 2, backgroundColor: Colors.green),
                          ),
                        );
                      }).toList(),
                      // Eğer 2 nokta varsa, bunlar arasında bir çizgi çiziyoruz
                      if (points.length == 2)
                        CustomPaint(
                          size: Size.infinite,
                          painter: LinePainter(
                              points[0].position * scale + offset,
                              points[1].position * scale + offset),
                        ),
                      // Noktalar arasındaki mesafeyi cm olarak gösteriyoruz
                      if (points.length == 2)
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Text(
                            'Distance: ${pxToCm(distanceBetweenPoints()).toStringAsFixed(2)} cm',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
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
                                        width = (width + details.delta.dx)
                                            .clamp(
                                                50,
                                                double
                                                    .infinity); // Min. genişlik
                                        height = (height + details.delta.dy)
                                            .clamp(
                                                50,
                                                double
                                                    .infinity); // Min. yükseklik
                                      });
                                    },
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
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
          ),
          // Image picker buttons
          Row(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Sol tarafa hizalama
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Merkeze hizalama
                    children: [
                      // Üst ok butonu
                      IconButton(
                        onPressed: () {
                          if (selectedPointIndex != null) {
                            setState(() {
                              points[selectedPointIndex!].position =
                                  points[selectedPointIndex!]
                                      .position
                                      .translate(0, -1); // Yukarı kaydırma
                            });
                          }
                        },
                        icon: Icon(Icons.arrow_upward),
                        iconSize: 30,
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Orta hizalama
                        children: [
                          // Sol yön butonu
                          IconButton(
                            onPressed: () {
                              if (selectedPointIndex != null) {
                                setState(() {
                                  points[selectedPointIndex!].position =
                                      points[selectedPointIndex!]
                                          .position
                                          .translate(-1, 0); // Sol kaydırma
                                });
                              }
                            },
                            icon: Icon(Icons.arrow_circle_left),
                            iconSize: 30,
                          ),
                          // Sağ yön butonu
                          IconButton(
                            onPressed: () {
                              if (selectedPointIndex != null) {
                                setState(() {
                                  points[selectedPointIndex!].position =
                                      points[selectedPointIndex!]
                                          .position
                                          .translate(1, 0); // Sağ kaydırma
                                });
                              }
                            },
                            icon: Icon(Icons.arrow_circle_right),
                            iconSize: 30,
                          ),
                        ],
                      ),
                      // Alt ok butonu
                      IconButton(
                        onPressed: () {
                          if (selectedPointIndex != null) {
                            setState(() {
                              points[selectedPointIndex!].position =
                                  points[selectedPointIndex!]
                                      .position
                                      .translate(0, 1); // Aşağı kaydırma
                            });
                          }
                        },
                        icon: Icon(Icons.arrow_circle_down_sharp),
                        iconSize: 40,
                      ),
                      SizedBox(height: 20), // Butonlar arasında boşluk
                      // Noktayı değiştir butonu
                    ],
                  ),
                  Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, size: 30),
                            onPressed: clearSelection,
                          ),
                          Text('Seçimi Kaldır')
                        ],
                      ),

                      // Noktayı Değiştir butonu
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.change_circle_outlined, size: 30),
                            onPressed: () {
                              // Noktayı değiştirme işlemi
                              setState(() {
                                if (selectedPointIndex == 1) {
                                  selectedPointIndex = 0;
                                } else {
                                  selectedPointIndex = 1;
                                }
                              });

                              // Show SnackBar when the point is changed
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Nokta değiştirildi!'),
                                  duration: Duration(
                                      seconds:
                                          1), // Duration for how long the SnackBar will show
                                  behavior: SnackBarBehavior
                                      .floating, // Makes the SnackBar float above the content
                                  backgroundColor: Colors
                                      .green, // Customize the color of the SnackBar
                                ),
                              );
                            },
                          ),
                          Text('Noktayı Değiştir')
                        ],
                      )
                    ],
                  ),
                  SizedBox(width: 130),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Kamera butonu
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.camera_alt, size: 30),
                            onPressed: _pickImageFromCamera,
                          ),
                        ],
                      ),

                      // Galeri butonu
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.photo_library, size: 30),
                            onPressed: _pickImageFromGallery,
                          ),
                        ],
                      ),

                      // Seçimi sil butonu
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Aşağı yön butonu

          // Clear button to reset points and lines
        ],
      ),
    );
  }
}

class Point {
  final String id;
  late Offset position;
  bool isSelected;
  Color color;

  Point(
      {required this.position,
      this.isSelected = false,
      this.color = Colors.green})
      : id = UniqueKey().toString();

  set setPosition(Offset newPosition) {
    position = newPosition;
  }
}

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double pointSpacing; // Noktalar arasındaki mesafe

  LinePainter(this.start, this.end, {this.pointSpacing = 10});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 3;

    // Çizgiyi iki nokta arasındaki mesafeye göre noktalara bölelim
    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    double distance = math.sqrt(dx * dx + dy * dy);
    int pointsCount = (distance / pointSpacing).floor();

    for (int i = 0; i <= pointsCount; i++) {
      double t = i / pointsCount; // t, çizginin üzerindeki pozisyonu belirler
      double x = start.dx + t * dx;
      double y = start.dy + t * dy;

      // Noktayı çiz
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
