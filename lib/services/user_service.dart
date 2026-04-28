import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future<void> saveUser(User user) async {
  try {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    // ✅ TRY GETTING FROM SERVER FIRST, FALLBACK TO CACHE
    DocumentSnapshot? doc;
    try {
      doc = await userRef.get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint("ℹ️ Firestore fetch delayed or offline: $e");
      try {
        doc = await userRef.get(const GetOptions(source: Source.cache));
      } catch (cacheError) {
        debugPrint("❌ Cache fetch also failed: $cacheError");
      }
    }

    // ✅ ONLY CREATE IF NOT EXISTS
    if (doc == null || !doc.exists) {
      await userRef.set({
        "uid": user.uid,
        "email": user.email?.toLowerCase(),
        "name": user.email!.split('@')[0],
        "bio": "",
        "imageUrl": "",
        "createdAt": FieldValue.serverTimestamp(), // Better than Timestamp.now()
      }, SetOptions(merge: true));

      print("✅ New user record created");
    } else {
      print("ℹ️ User already exists in Firestore");
    }

  } catch (e) {
    print("🔥 Firestore error in saveUser: $e");
  }
}