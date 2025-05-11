
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/scan_screen.dart';

Widget _buildProductColumn(BuildContext context, int columnNumber) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 24,
          backgroundColor: columnNumber == 1 ? Colors.purple : Colors.blue,
          child: Text(
            columnNumber.toString(),
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 60),
          color: Colors.grey,
          onPressed: () {},
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScannerScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Text('SCAN', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}

