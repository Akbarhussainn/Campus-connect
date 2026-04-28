
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


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

  // ☁️ CLOUDINARY UNSIGNED UPLOAD (STRICT)
Future<String> uploadToCloudinary(XFile imageFile) async {
  const String cloudName = "dsnvja3wr";
  const String uploadPreset = "campusconnect_upload";

  final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

  try {
    print("🚀 Cloudinary Unsigned Upload started...");
    
    final bytes = await imageFile.readAsBytes();
    
    // Create a clean MultipartRequest
    final request = http.MultipartRequest("POST", url);
    
    // ✅ Include cloud_name in fields (sometimes required for Web)
    request.fields['upload_preset'] = uploadPreset;
    request.fields['cloud_name'] = cloudName;
    
    // ✅ Add the file
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: imageFile.name,
    ));

    // ✅ Force simple headers to avoid pre-flight confusion
    request.headers.addAll({
      'Accept': 'application/json',
    });

    print("📤 Sending to: $url");
    print("📦 Fields: ${request.fields}");

    final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);

    print("📡 Response Status: ${response.statusCode}");
    print("📄 Response Body: ${response.body}");

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final secureUrl = jsonResponse['secure_url'];
      print("✅ secure_url received: $secureUrl");
      return secureUrl;
    } else {
      final errorMsg = jsonResponse['error']?['message'] ?? "Unknown Cloudinary error";
      print("❌ Cloudinary Error: $errorMsg");
      throw Exception("Cloudinary Error: $errorMsg");
    }
  } catch (e) {
    print("❌ Cloudinary Exception: $e");
    rethrow;
  }
}
  // 💾 SAVE PROFILE

 Future<void> saveProfile() async {
  if (nameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fill all fields")),
    );
    return;
  }

  setState(() => loading = true);

  try {
    String imageUrl = "https://via.placeholder.com/300";

    if (_image != null) {
      print("🚀 Uploading to Cloudinary...");
      imageUrl = await uploadToCloudinary(_image!);
    } else {
      print("🚀 No image selected, using placeholder");
    }

    print("👤 Saving profile to Firestore...");

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .set({
      "uid": user!.uid,
      "email": user!.email,
      "name": nameController.text.trim(),
      "bio": bioController.text.trim(),
      "imageUrl": imageUrl,
      "updatedAt": FieldValue.serverTimestamp(), 
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).timeout(const Duration(seconds: 15), onTimeout: () {
      print("⚠️ Firestore write is slow, but should sync eventually.");
      // Do not throw here, allow user to proceed
    });

    print("✅ Firestore sync initiated");

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