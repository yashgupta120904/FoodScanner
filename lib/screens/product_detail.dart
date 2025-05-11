import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodscanner_2/screens/HomeScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:foodscanner_2/widgets/bottom_nav.dart';



class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _analysisResult = {};

  // Counts for UI display
  int _allergicIngredientCount = 0;
  int _concernsCount = 0;
  int _allergicCount = 0;
  int _alternativesCount = 0;

  @override
  void initState() {
    super.initState();
    _analyzeProductImage();
  }

  Future<void> _analyzeProductImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create multipart request
      final uri = Uri.parse('https://e907-103-121-234-140.ngrok-free.app/analyze'); // Use your API URL
      final request = http.MultipartRequest('POST', uri);

      // Add file to request
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final filename = widget.imagePath.split('/').last;

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ));

      // Send request
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(respStr);
        setState(() {
          _analysisResult = data;

          // Set counts from API response
          _allergicIngredientCount = (data['concerns']['allergens'] as List).length;

          // Calculate concerns count (harmful ingredients + banned countries)
          _concernsCount = (data['concerns']['harmful_ingredients'] as List).length;
          if (data['concerns']['banned_by_country'] is Map) {
            _concernsCount += (data['concerns']['banned_by_country'] as Map).length;
          }

          // Allergens count
          _allergicCount = (data['concerns']['allergens'] as List).length;

          // Alternatives count
          _alternativesCount = (data['alternatives'] as List).length;

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('API Error: ${respStr}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Exception during API call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    int qualityScore = _isLoading ? 0 : (_analysisResult['quality_score'] ?? 0);
    Color scoreColor = Colors.blue;
    String topMessage = "Analyzing...";
    String bottomMessage = "Please wait...";

    if (!_isLoading) {
      if (qualityScore <= 40) {
        scoreColor = Colors.red;
        topMessage = "Caution !!";
        bottomMessage = "Unhealthy food.";
      } else if (qualityScore <= 70) {
        scoreColor = Colors.orange;
        topMessage = "Moderate !!";
        bottomMessage = "Consume in moderation.";
      } else {
        scoreColor = Colors.green;
        topMessage = "Enjoy !!";
        bottomMessage = "This is healthy food.";
      }
    }
    return BottomNavWithScanner(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back,size: 25,),
                onPressed: () {
                  // Navigate to the HomeScreen instead of CompareProductsScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePageWork()),
                  );
                },
              ),
              title: Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.025),
                child: Text(
                  'Product Detail',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              actions: [
                IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
              ],
            ),
            Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.035,
                  right: screenWidth * 0.125,
                  child: Icon(Icons.bookmark_border, size: screenWidth * 0.075, color: Colors.black),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.05),
                  child: Center(
                    child: Container(
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.25,
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          // Top-left corner
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: screenWidth * 0.2,
                              height: screenHeight * 0.1,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(width: screenWidth * 0.03, color: Colors.grey),
                                  left: BorderSide(width: screenWidth * 0.03, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          // Top-right corner
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: screenWidth * 0.2,
                              height: screenHeight * 0.1,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(width: screenWidth * 0.03, color: Colors.grey),
                                  right: BorderSide(width: screenWidth * 0.03, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          // Bottom-left corner
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: screenWidth * 0.2,
                              height: screenHeight * 0.1,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(width: screenWidth * 0.03, color: Colors.grey),
                                  left: BorderSide(width: screenWidth * 0.03, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          // Bottom-right corner
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: screenWidth * 0.2,
                              height: screenHeight * 0.1,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(width: screenWidth * 0.03, color: Colors.grey),
                                  right: BorderSide(width: screenWidth * 0.03, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          // Center number - Quality score from API
                          Center(
                            child: Text(
                              _isLoading ? '...' : '${_analysisResult['quality_score'] ?? 87}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.3,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
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
            SizedBox(height: screenHeight * 0.01),
            Text(
              topMessage,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              bottomMessage,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.05,
                color: scoreColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Product Label
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.075),
                child: Text(
                  "Product :",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Product image with fixed size and overflow-safe
                Container(
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    color: Colors.grey[200],
                  ),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.broken_image, size: screenWidth * 0.1, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.0625),

                // Allergic Ingredient count box with Flexible to avoid overflow
                Flexible(
                  child: Container(
                    height: screenHeight * 0.125,
                    width: screenWidth * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Allergic\nIngredient:",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Container(
                          width: screenWidth * 0.075,
                          height: screenWidth * 0.075,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.red,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                          ),
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                              width: screenWidth * 0.0375,
                              height: screenWidth * 0.0375,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                            )
                                : Text(
                              "$_allergicIngredientCount",
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),

            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.075),
              child: Row(
                children: [
                  Text(
                    "Concerns :",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.4375),
                  Container(
                    width: screenWidth * 0.075,
                    height: screenWidth * 0.075,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      border: Border.all(
                        color: Colors.red,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                        width: screenWidth * 0.0375,
                        height: screenWidth * 0.0375,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        "$_concernsCount",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: screenWidth * 0.825,
              child: Card(
                color: Colors.red,
                elevation: 5,
                shadowColor: Colors.yellow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Harmful Ingredients:",
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.004),
                      Text(
                        _isLoading
                            ? 'Loading...'
                            : (_analysisResult['concerns']?['harmful_ingredients'] as List?)?.join(', ') ?? 'None found',
                        style: GoogleFonts.poppins(fontSize: screenWidth * 0.04),
                      ),
                      SizedBox(height: screenHeight * 0.012),
                      Text(
                        "Banned by Country:",
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.004),
                      Text(
                        _isLoading
                            ? 'Loading...'
                            : (_analysisResult['concerns']?['banned_by_country'] as Map?)?.keys.join(', ') ?? 'None found',
                        style: GoogleFonts.poppins(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.075),
              child: Row(
                children: [
                  Text(
                    "Allergic :",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.4875),
                  Container(
                    width: screenWidth * 0.075,
                    height: screenWidth * 0.075,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      border: Border.all(
                        color: Colors.red,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                        width: screenWidth * 0.0375,
                        height: screenWidth * 0.0375,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        "$_allergicCount",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.02),
            Container(
              width: screenWidth * 0.825,
              child: Card(
                color: Colors.red,
                elevation: 5,
                shadowColor: Colors.yellow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Allergic Ingredients:",
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.004),
                      Text(
                        _isLoading
                            ? 'Loading...'
                            : (_analysisResult['concerns']?['allergens'] as List?)?.join(', ') ?? 'None found',
                        style: GoogleFonts.poppins(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.075),
              child: Row(
                children: [
                  Text(
                    "Other Things :",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.3625),
                  Container(
                    width: screenWidth * 0.075,
                    height: screenWidth * 0.075,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      border: Border.all(
                        color: Colors.green,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                        width: screenWidth * 0.0375,
                        height: screenWidth * 0.0375,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        "$_alternativesCount",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.02),
            Container(
              width: screenWidth * 0.825,
              child: Card(
                color: Colors.green,
                elevation: 5,
                shadowColor: Colors.yellow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Alternatives:",
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.004),
                      Text(
                        _isLoading
                            ? 'Loading...'
                            : (_analysisResult['alternatives'] as List?)?.join(', ') ?? 'None found',
                        style: GoogleFonts.poppins(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}