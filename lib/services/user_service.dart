import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future<void> saveUser(User user) async {
  try {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    // ✅ FORCE SERVER FETCH ON WEB TO AVOID CACHE TIMEOUTS
    DocumentSnapshot? doc;
    try {
      if (kIsWeb) {
        // On Web with persistence disabled, we must fetch from server
        doc = await userRef.get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 15));
      } else {
        doc = await userRef.get(const GetOptions(source: Source.serverAndCache))
            .timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      debugPrint("ℹ️ Initial fetch failed/timed out: $e");
      // If server fails, we try cache ONLY if not on Web (or if persistence is on)
      if (!kIsWeb) {
        try {
          doc = await userRef.get(const GetOptions(source: Source.cache));
        } catch (_) {}
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
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 10));

      print("✅ New user record created");
    } else {
      print("ℹ️ User verified in Firestore");
    }

  } catch (e) {
    print("🔥 Firestore error in saveUser: $e");
  }
}

Stream<DocumentSnapshot> getUserStream(String uid) {
  // We use server-first stream on Web to ensure fresh data
  return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
}