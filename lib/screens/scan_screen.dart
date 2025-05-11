import 'package:flutter/material.dart';
import 'package:foodscanner_2/screens/product_detail.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';



class ScannerScreen extends StatefulWidget {
  final bool returnImage;

  const ScannerScreen({super.key,this.returnImage=false });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanning = true;
  double _scanningProgress = 0.0;
  Timer? _timer;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    _startScanningAnimation();
  }

  void _startScanningAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _scanningProgress += 0.05;
        if (_scanningProgress >= 1.0) {
          _scanningProgress = 0.0;
        }
      });
    });
  }

  // Future<void> _getImage(ImageSource source) async {
  //   final XFile? pickedFile = await _picker.pickImage(source: source);
  //   setState(() {
  //     if (pickedFile != null) {
  //       _imageFile = File(pickedFile.path);
  //       _showOptions = false;
  //       // Start scanning effect after image is selected
  //       _isScanning = true;
  //
  //       // Add a slight delay to show the scanning animation before navigating
  //       Future.delayed(const Duration(milliseconds: 1500), () {
  //         // Navigate to the product detail screen with the image path
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ProductDetailScreen(imagePath: pickedFile.path),
  //           ),
  //         );
  //       });
  //     }
  //   });
  // }
  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _showOptions = false;
        _isScanning = true;

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (widget.returnImage) {
            // Return the image path to the previous screen
            Navigator.pop(context, pickedFile.path);
          } else {
            // Navigate to ProductDetailScreen if not returning image
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(imagePath: pickedFile.path),
              ),
            );
          }
        });
      }
    });
  }



  void _toggleImageSourceOptions() {
    setState(() {
      _showOptions = !_showOptions;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Content area (camera feed or selected image)
          Positioned.fill(
            child: _imageFile != null
                ? Image.file(
              _imageFile!,
              fit: BoxFit.cover,
            )
                : Container(
              color: const Color(0xFF8a8e23), // Yellowish-green background as fallback
              child: const Center(
                child: Text(
                  'Select or capture an image',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  // Handle close button press - could navigate back
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),

          // Scanner UI overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Scanning circle
                  GestureDetector(
                    onTap: _toggleImageSourceOptions,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                          value: _isScanning ? null : 1.0,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Text
                  Text(
                    _imageFile != null ? "Scanning..." : "Tap to select image",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Flash/camera options button
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: _toggleImageSourceOptions,
              ),
            ),
          ),

          // Image source selection options
          if (_showOptions)
            Positioned(
              top: 100,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                width: 150,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Camera'),
                      onTap: () => _getImage(ImageSource.camera),
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Gallery'),
                      onTap: () => _getImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}