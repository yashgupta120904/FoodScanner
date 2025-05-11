import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UiHelper {
  static Widget customTextField(
      TextEditingController controller,
      IconData icon,
      String hintText,
      bool isPassword,
      TextInputType inputType) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool obscureText = isPassword;
        return TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: inputType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.green),
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.green,
              ),
              onPressed: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
            )
                : null,
          ),
        );
      },
    );
  }
}