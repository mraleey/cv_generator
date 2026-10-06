import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cv_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveCV(CVModel cv) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cvs')
        .add({
      ...cv.toJson(),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<List<CVModel>> getSavedCVs() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final querySnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cvs')
        .orderBy('created_at', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => CVModel.fromJson(doc.data()))
        .toList();
  }
}
