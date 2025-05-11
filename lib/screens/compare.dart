import 'package:flutter/material.dart';
import 'package:foodscanner_2/screens/HomeScreen.dart';
import 'package:foodscanner_2/screens/scan_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import '../widgets/bottom_nav.dart';

import 'AllergyInfoScreen.dart';

import '../models/compare_services.dart';
import 'MoreScreen.dart';

void main() {
  runApp(MaterialApp(home: CompareProductsScreen()));
}

class CompareProductsScreen extends StatefulWidget {
  const CompareProductsScreen({Key? key}) : super(key: key);

  @override
  State<CompareProductsScreen> createState() => _CompareProductsScreenState();
}

class _CompareProductsScreenState extends State<CompareProductsScreen> {
  String? _imagePath1;
  String? _imagePath2;

  // Add variables to track selected allergen images
  String? _allergenLabel1;
  String? _allergenLabel2;
  String? _allergenImagePath1;
  String? _allergenImagePath2;

  // Flag to determine if the image is from camera or allergen selection
  bool _isAllergenImage1 = false;
  bool _isAllergenImage2 = false;

  // Comparison result
  Map<String, dynamic>? _comparisonResult;
  bool _showResult = false;
  bool _isLoading = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkApiConnection();
  }

  // Check if the API server is accessible
  Future<void> _checkApiConnection() async {
    try {
      final isConnected = await CompareService.testConnection();
      setState(() {
        _isConnected = isConnected;
      });
      if (!isConnected) {
        _showErrorDialog('Warning: Cannot connect to the comparison service. Some features may be limited.');
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BottomNavWithScanner(
      initialIndex: 2,
      body: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,size: 25),
            onPressed: () => {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePageWork()),
            )
          }
          ),
          title: Text('Compare Products', style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold
          ),),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05, vertical: size.height * 0.03),
            child: Column(
              children: [
                // Product selection section
                Container(
                  height: size.height * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: size.width * 0.4,
                        child: _buildProductColumn(context, 1, size),
                      ),
                      SizedBox(width: size.width * 0.05),
                      SizedBox(
                        width: size.width * 0.4,
                        child: _buildProductColumn(context, 2, size),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                SizedBox(
                  width: size.width * 0.5,
                  height: size.height * 0.07,
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: (_imagePath1 != null ||
                        _allergenLabel1 != null) &&
                        (_imagePath2 != null || _allergenLabel2 != null)
                        ? () {
                      _compareProducts();
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade300,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'COMPARE',
                      style: GoogleFonts.poppins(fontSize: size.width * 0.05,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Connection status indicator
                if (!_isConnected)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, color: Colors.red, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Offline mode',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Comparison result section
                if (_showResult && _comparisonResult != null) ...[
                  SizedBox(height: size.height * 0.03),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Comparison Result',
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Product 1 image and label
                            Column(
                              children: [
                                Container(
                                  width: size.width * 0.3,
                                  height: size.width * 0.3,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[200],
                                  ),
                                  child: _isAllergenImage1 &&
                                      _allergenImagePath1 != null
                                      ? Image.asset(
                                      _allergenImagePath1!, fit: BoxFit.cover)
                                      : _imagePath1 != null
                                      ? Image.file(
                                      File(_imagePath1!), fit: BoxFit.cover)
                                      : Container(),
                                ),
                                if (_allergenLabel1 != null)
                                  Container(
                                    width: size.width * 0.3,
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _allergenLabel1!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.width * 0.035,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: size.width * 0.05),
                            // Product 2 image and label
                            Column(
                              children: [
                                Container(
                                  width: size.width * 0.3,
                                  height: size.width * 0.3,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[200],
                                  ),
                                  child: _isAllergenImage2 &&
                                      _allergenImagePath2 != null
                                      ? Image.asset(
                                      _allergenImagePath2!, fit: BoxFit.cover)
                                      : _imagePath2 != null
                                      ? Image.file(
                                      File(_imagePath2!), fit: BoxFit.cover)
                                      : Container(),
                                ),
                                if (_allergenLabel2 != null)
                                  Container(
                                    width: size.width * 0.3,
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _allergenLabel2!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.width * 0.035,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Error message if present
                        if (_comparisonResult!.containsKey('error'))
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Error',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _comparisonResult!['error'].toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.035,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                        // Only show these sections if there's no error
                        if (!_comparisonResult!.containsKey('error')) ...[
                          // Better nutritional value
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Better Nutritional Value',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _comparisonResult!['better_nutritional_value']?.toString() ?? "No data available",
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.035,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          // Detailed comparison - IMPROVED FORMAT
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    'Comparison Details',
                                    style: GoogleFonts.poppins(
                                      fontSize: size.width * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 12),
                                ..._buildFormattedComparisonDetails(),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          // Side effects
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Potential Side Effects When Consumed Together',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _formatSideEffects(_comparisonResult!['potential_side_effects']),
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.035,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // New method to build formatted comparison details
  List<Widget> _buildFormattedComparisonDetails() {
    final size = MediaQuery.of(context).size;
    final details = _comparisonResult!['comparison_details'];
    if (details == null) {
      return [
        Center(
          child: Text(
            "No detailed comparison available",
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.035,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    try {
      // Try to parse and format the comparison details
      final Map<String, dynamic> formattedDetails = _parseComparisonDetails(details.toString());
      List<Widget> detailWidgets = [];

      formattedDetails.forEach((category, content) {
        detailWidgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatCategoryTitle(category),
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 4),
                if (content is Map<String, dynamic>) ...[
                  ...content.entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(left: 16, bottom: 4),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.035,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: "${_formatSubcategoryTitle(entry.key)}: ",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            TextSpan(text: entry.value.toString()),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ] else if (content is String) ...[
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      content,
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.035,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      });

      return detailWidgets;
    } catch (e) {
      // Fallback to simple text if parsing fails
      return [
        Text(
          details.toString(),
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.035,
          ),
          textAlign: TextAlign.left,
        ),
      ];
    }
  }

  // Helper method to parse comparison details
  Map<String, dynamic> _parseComparisonDetails(String detailsStr) {
    // This method attempts to parse the JSON-like string into a structured map
    Map<String, dynamic> result = {};

    // Remove curly braces and unnecessary characters
    String cleanStr = detailsStr.replaceAll('{', '').replaceAll('}', '').trim();

    // Split by main categories (assuming they're separated by commas and not nested)
    List<String> mainSections = [];
    int bracketCount = 0;
    int lastSplitIndex = 0;

    for (int i = 0; i < cleanStr.length; i++) {
      if (cleanStr[i] == '{') bracketCount++;
      if (cleanStr[i] == '}') bracketCount--;

      if (cleanStr[i] == ',' && bracketCount == 0) {
        mainSections.add(cleanStr.substring(lastSplitIndex, i).trim());
        lastSplitIndex = i + 1;
      }
    }
    // Add the last section
    if (lastSplitIndex < cleanStr.length) {
      mainSections.add(cleanStr.substring(lastSplitIndex).trim());
    }

    // Process each main section
    for (var section in mainSections) {
      List<String> parts = section.split(':');
      if (parts.length >= 2) {
        String key = parts[0].replaceAll('"', '').trim();
        String value = parts.sublist(1).join(':').trim();

        // Check if value is a nested object
        if (value.startsWith('{') && value.endsWith('}')) {
          // Parse nested object
          Map<String, dynamic> nestedMap = {};
          String nestedStr = value.substring(1, value.length - 1);

          // Split nested sections
          List<String> nestedParts = _splitNestedParts(nestedStr);

          for (var nestedPart in nestedParts) {
            List<String> subParts = nestedPart.split(':');
            if (subParts.length >= 2) {
              String subKey = subParts[0].replaceAll('"', '').trim();
              String subValue = subParts.sublist(1).join(':').trim();
              nestedMap[subKey] = subValue;
            }
          }

          result[key] = nestedMap;
        } else {
          result[key] = value;
        }
      }
    }

    return result;
  }

  // Helper method to split nested parts respecting nested structures
  List<String> _splitNestedParts(String str) {
    List<String> parts = [];
    int bracketCount = 0;
    int lastSplitIndex = 0;

    for (int i = 0; i < str.length; i++) {
      if (str[i] == '{') bracketCount++;
      if (str[i] == '}') bracketCount--;

      if (str[i] == ',' && bracketCount == 0) {
        parts.add(str.substring(lastSplitIndex, i).trim());
        lastSplitIndex = i + 1;
      }
    }

    // Add the last part
    if (lastSplitIndex < str.length) {
      parts.add(str.substring(lastSplitIndex).trim());
    }

    return parts;
  }

  // Format category titles
  String _formatCategoryTitle(String category) {
    return category
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  // Format subcategory titles
  String _formatSubcategoryTitle(String subcategory) {
    return subcategory
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  // Helper method to format side effects properly
  String _formatSideEffects(dynamic sideEffects) {
    if (sideEffects == null) {
      return "No known side effects";
    }

    if (sideEffects is List) {
      return sideEffects.isEmpty
          ? "No known side effects"
          : "• ${sideEffects.map((e) => e.toString()).join("\n• ")}";
    }

    return sideEffects.toString();
  }

  Widget _buildProductColumn(BuildContext context, int columnNumber, Size size) {
    // Get the correct image source based on the column and image type
    Widget imageWidget;
    String? productName;

    if (columnNumber == 1) {
      if (_isAllergenImage1 && _allergenImagePath1 != null) {
        imageWidget = Image.asset(
          _allergenImagePath1!,
          fit: BoxFit.cover,
        );
        productName = _allergenLabel1;
      } else if (_imagePath1 != null) {
        imageWidget = Image.file(
          File(_imagePath1!),
          fit: BoxFit.cover,
        );
      } else {
        imageWidget = Icon(Icons.add_circle_outline, size: size.width * 0.15,
            color: Colors.grey);
        productName = null;
      }
    } else {
      if (_isAllergenImage2 && _allergenImagePath2 != null) {
        imageWidget = Image.asset(
          _allergenImagePath2!,
          fit: BoxFit.cover,
        );
        productName = _allergenLabel2;
      } else if (_imagePath2 != null) {
        imageWidget = Image.file(
          File(_imagePath2!),
          fit: BoxFit.cover,
        );
      } else {
        imageWidget = Icon(Icons.add_circle_outline, size: size.width * 0.15,
            color: Colors.grey);
        productName = null;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: size.height * 0.02),
          CircleAvatar(
            radius: size.width * 0.07,
            backgroundColor: columnNumber == 1 ? Colors.purple : Colors.blue,
            child: Text(
              columnNumber.toString(),
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          // Product image or add icon
          Container(
            width: size.width * 0.25,
            height: size.width * 0.25,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: (columnNumber == 1 &&
                (_imagePath1 != null || _allergenImagePath1 != null)) ||
                (columnNumber == 2 &&
                    (_imagePath2 != null || _allergenImagePath2 != null))
                ? imageWidget
                : InkWell(
              onTap: () async {
                _openAllergenSelector(columnNumber);
              },
              child: imageWidget,
            ),
          ),
          if (productName != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
              child: Text(
                productName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.035,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // SCAN button
              SizedBox(
                width: size.width * 0.18,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScannerScreen(returnImage: true),
                      ),
                    );
                    if (result != null && result is String) {
                      setState(() {
                        if (columnNumber == 1) {
                          _imagePath1 = result;
                          _isAllergenImage1 = false;
                          _allergenImagePath1 = null;
                          _allergenLabel1 = null;
                        } else {
                          _imagePath2 = result;
                          _isAllergenImage2 = false;
                          _allergenImagePath2 = null;
                          _allergenLabel2 = null;
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'SCAN',
                    style: GoogleFonts.poppins(fontSize: size.width * 0.03,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Add SELECT button
              SizedBox(
                width: size.width * 0.18,
                child: ElevatedButton(
                  onPressed: () {
                    _openAllergenSelector(columnNumber);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'SELECT',
                    style: GoogleFonts.poppins(fontSize: size.width * 0.03,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
        ],
      ),
    );
  }

  // Method to open allergen selector
  void _openAllergenSelector(int columnNumber) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) =>
          AllergyInfoPopup(
            onItemSelected: (label, imagePath) {
              // This callback can be used if needed
            },
          ),
    );

    if (result != null) {
      setState(() {
        if (columnNumber == 1) {
          _allergenLabel1 = result['label'];
          _allergenImagePath1 = result['imagePath'];
          _isAllergenImage1 = true;
          _imagePath1 = null; // Clear any camera image
        } else {
          _allergenLabel2 = result['label'];
          _allergenImagePath2 = result['imagePath'];
          _isAllergenImage2 = true;
          _imagePath2 = null; // Clear any camera image
        }
      });
    }
  }

  // Method to compare products using the CompareService
  Future<void> _compareProducts() async {
    // Get the food item names (from either scanned images or selected allergens)
    String? food1 = _allergenLabel1 ?? (_imagePath1 != null ? 'Scanned Item 1' : null);
    String? food2 = _allergenLabel2 ?? (_imagePath2 != null ? 'Scanned Item 2' : null);

    if (food1 == null || food2 == null) {
      _showErrorDialog('Please select both food items for comparison');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the CompareService class to make the API call
      final result = await CompareService.compareFood(
        food1: food1,
        food2: food2,
      );

      setState(() {
        _comparisonResult = result;
        _showResult = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _comparisonResult = {
          'error': e.toString(),
          'comparison_details': 'An error occurred during comparison.',
        };
        _showResult = true;
      });
    }
  }

  // Method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}