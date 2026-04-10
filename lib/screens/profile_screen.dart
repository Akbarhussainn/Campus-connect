
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();

  XFile? _image;   // ✅ WEB FRIENDLY
  bool loading = false;

  final user = FirebaseAuth.instance.currentUser;

  

  // 📸 PICK IMAGE
 Future<void> pickImage() async {
  final ImagePicker picker = ImagePicker();

  final XFile? pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (pickedFile != null) {
    setState(() {
      _image = pickedFile;
    });
  } else {
    print("No image selected");
  }
}

  // ☁️ UPLOAD IMAGE
Future<String> uploadImage() async {
  if (_image == null) {
    throw Exception("No image selected");
  }

  final ref = FirebaseStorage.instance
      .ref()
      .child('profile_images/${user!.uid}.jpg');

  final bytes = await _image!.readAsBytes();

  await ref.putData(bytes);

  return await ref.getDownloadURL();
}
  // 💾 SAVE PROFILE

 Future<void> saveProfile() async {
  if (_image == null || nameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fill all fields")),
    );
    return;
  }

  setState(() => loading = true);

  try {
    print("🚀 Upload started");

    final imageUrl = await uploadImage();

    print("✅ Image uploaded");

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .set({
      "uid": user!.uid,
      "email": user!.email,
      "name": nameController.text.trim(),
      "bio": bioController.text.trim(),
      "imageUrl": imageUrl,
      "createdAt": Timestamp.now(),
    }, SetOptions(merge: true));

    print("✅ Firestore saved");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile saved successfully")),
    );

    Navigator.pushReplacementNamed(context, '/dashboard');

  } catch (e) {
    print("🔥 ERROR: $e");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}")),
    );

  } finally {
    if (mounted) setState(() => loading = false);
  }
}

  // 🚪 LOGOUT
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f172a),

      appBar: AppBar(
        backgroundColor: const Color(0xff1e293b),
        title: const Text("Complete Profile"),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // 📸 IMAGE PICKER
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey,
                backgroundImage: _image != null
    ? Image.network(_image!.path).image
    : null,
                child: _image == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              user?.email ?? "",
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 20),

            // 👤 NAME
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration("Name"),
            ),

            const SizedBox(height: 15),

            // 📝 BIO
            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration("Bio"),
            ),

            const SizedBox(height: 30),

            // 💾 SAVE BUTTON
            ElevatedButton(
              onPressed: loading ? null : saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xff1e293b),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}