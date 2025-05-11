import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SignInController extends GetxController
{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signInMethod
      (
      String UserEmail,
      String Password,
      )
  async{
    try{
      EasyLoading.show(status: 'Please Wait');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: UserEmail, password: Password);

      EasyLoading.dismiss();
      return userCredential;
    }on FirebaseAuthException catch(e)
    {
      EasyLoading.dismiss();
      Get.snackbar("Error Encountered", "$e",snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.purple.shade100,
        colorText: Colors.black,

      );
    }
  }
}