import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveUser(User user) async {
  try {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final doc = await userRef.get();

    // ✅ ONLY CREATE IF NOT EXISTS
    if (!doc.exists) {
      await userRef.set({
        "uid": user.uid,
        "email": user.email?.toLowerCase(),
        "name": user.email!.split('@')[0],
        "bio": "",
        "imageUrl": "",
        "createdAt": Timestamp.now(),
      });

      print("✅ New user created");
    } else {
      print("ℹ️ User already exists (not overwriting)");
    }

  } catch (e) {
    print("🔥 Firestore error: $e");
  }
}