import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveUser(User user) async {
  try {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userRef.set({
      "uid": user.uid,
      "email": user.email?.toLowerCase(),
      "name": user.email!.split('@')[0],
      "createdAt": Timestamp.now(),
    }, SetOptions(merge: true));

    print("✅ User saved");

  } catch (e) {
    print("🔥 Firestore error: $e");
  }
}