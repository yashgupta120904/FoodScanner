import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodscanner_2/Controller/Sign-up-Controller.dart';
import 'package:foodscanner_2/screens/signin_screen.dart';
import 'package:foodscanner_2/widgets/uihelper.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  bool obscurePassword = true;
  final SignUpController signUpController = Get.put(SignUpController());

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Create ',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            Text(
              'Account',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.green),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign Up',
                    style: GoogleFonts.poppins(
                        fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Create your account to continue.',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 20),

                  UiHelper.customTextField(
                    fullNameController,
                    Icons.person,
                    'Full Name',
                    false,
                    TextInputType.text,
                  ),
                  SizedBox(height: 16),

                  UiHelper.customTextField(
                    emailController,
                    Icons.email,
                    'Email Address',
                    false,
                    TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),

                  UiHelper.customTextField(
                    phoneNumberController,
                    Icons.phone,
                    'Mobile Number',
                    false,
                    TextInputType.phone,
                  ),
                  SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.green),
                      hintText: 'Password',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();
                      String phoneNumber = phoneNumberController.text.trim();
                      String fullName = fullNameController.text.trim();

                      // Check if any field is empty
                      if (email.isEmpty || password.isEmpty || phoneNumber.isEmpty || fullName.isEmpty) {
                        Get.snackbar(
                          "Error 🔥",
                          "Please enter all fields!",
                          backgroundColor: Colors.red.shade100,
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                      // Check if phone number is exactly 10 digits
                      else if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
                        Get.snackbar(
                          "Error 🔥",
                          "Please enter a valid 10-digit phone number!",
                          backgroundColor: Colors.red.shade100,
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                      // Proceed with sign-up if all validations pass
                      else {
                        try {
                          EasyLoading.show(status: 'Creating account...', maskType: EasyLoadingMaskType.black);

                          UserCredential? userCredential = await signUpController.signUpMethod(
                            fullName,
                            email,
                            password,
                            phoneNumber,
                          );

                          EasyLoading.dismiss();

                          if (userCredential != null) {
                            Get.snackbar(
                              "Verification Email Sent 📧",
                              "Check Your Email",
                              backgroundColor: Colors.green.shade100,
                              colorText: Colors.black,
                              snackPosition: SnackPosition.TOP,
                            );
                            await FirebaseAuth.instance.signOut();
                            Get.offAll(SignInScreen());
                          } else {
                            Get.snackbar(
                              "Signup Failed",
                              "Oops, something went wrong!",
                              backgroundColor: Colors.orange.shade100,
                              colorText: Colors.black,
                              snackPosition: SnackPosition.TOP,
                            );
                          }
                        } catch (e) {
                          EasyLoading.dismiss();
                          Get.snackbar(
                            "Error",
                            "Please try again: $e",
                            backgroundColor: Colors.red.shade100,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                  Text(
                    'By clicking Create Account, you agree to our Terms & Conditions.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  ),

                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ",
                          style: GoogleFonts.poppins(fontSize: 14)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => SignInScreen()));
                        },
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}