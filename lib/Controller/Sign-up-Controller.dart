import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodscanner_2/models/user_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signUpMethod(
      String fullName,
      String userEmail,
      String userPassword,
      String phoneNumber,
      ) async {
    try {
      EasyLoading.show(status: 'Please wait...');
      // Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Create user model (Password not stored for security reasons)
      UserModel userModel = UserModel(
        uId: userCredential.user!.uid,
        email: userEmail,
        fullName: fullName,
        phone: phoneNumber,
        Password: userPassword
      );

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(userModel.toMap());

      EasyLoading.dismiss();
      return userCredential;

    } catch (e) {
      EasyLoading.dismiss();
      String errorMessage = 'Something went wrong!';

      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Email already registered. Try logging in.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email format.';
        }
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
      return null;
    }
  }
}
