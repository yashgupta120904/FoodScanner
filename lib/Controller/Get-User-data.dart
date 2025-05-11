import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class GetUserDataController extends GetxController{
  final FirebaseFirestore _firebaseFirestore =FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Object?>>> getUserData(String uId)async
  {
    final QuerySnapshot userData = await _firebaseFirestore.collection('user').where('uId',isEqualTo: uId).get();
    return userData.docs;
  }
}