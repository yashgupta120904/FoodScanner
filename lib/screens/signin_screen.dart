// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' show UserCredential;
import 'package:flutter/material.dart';
import 'package:foodscanner_2/Controller/Get-User-data.dart' show GetUserDataController;
import 'package:foodscanner_2/screens/HomeScreen.dart';
import 'package:foodscanner_2/screens/signup_screen.dart';
import 'package:foodscanner_2/widgets/uihelper.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Controller/Sign-in-Controller.dart' show SignInController;


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  final SignInController signInController = Get.put(SignInController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome ',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            Text(
              'Back!',
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
                  GestureDetector(
                    onTap: ()
                    {
                    },
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Sign in to continue',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  UiHelper.customTextField(
                    emailController, Icons.mail, 'Enter Your Email', false, TextInputType.emailAddress,
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
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async{
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();

                      if(email.isEmpty || password.isEmpty)
                      {
                        Get.snackbar("Error", "Please Enter all Detail",
                            backgroundColor: Colors.purple.shade100,
                            colorText: Colors.black
                        );
                      }
                      else
                      {
                        UserCredential? userCredential = await signInController.signInMethod(email, password);
                        var userData = await GetUserDataController().getUserData(userCredential!.user!.uid);
                        if(userCredential != null)
                        {
                          if(userCredential.user!.emailVerified)
                          {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePageWork()));
                            Get.snackbar("Congratulation!", "Login Successfully",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.purple.shade100,
                                colorText: Colors.black);


                            // }
                          }
                          else
                          {
                            Get.snackbar("Error", "Please Verify Your Email ",
                                backgroundColor: Colors.purple.shade100,
                                snackPosition: SnackPosition.TOP,
                                colorText: Colors.black

                            );
                          }
                        }
                        else
                        {

                          Get.snackbar("Error", "Please Try Again",
                              backgroundColor: Colors.purple.shade100,
                              colorText: Colors.black);
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
                      'Sign In',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: GoogleFonts.poppins(fontSize: 14)),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}