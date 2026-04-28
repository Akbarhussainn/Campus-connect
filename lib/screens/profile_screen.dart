
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();

  XFile? _image;
  bool isSaving = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  // 📸 PICK IMAGE
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() => _image = pickedFile);
    }
  }

  // ☁️ CLOUDINARY UPLOAD
  Future<String> uploadToCloudinary(XFile imageFile) async {
    const String cloudName = "dsnvja3wr";
    const String uploadPreset = "campusconnect_upload";
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    try {
      print("🚀 Cloudinary request started...");
      final bytes = await imageFile.readAsBytes();
      final request = http.MultipartRequest("POST", url);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['cloud_name'] = cloudName;
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name));
      request.headers.addAll({'Accept': 'application/json'});

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        print("✅ Cloudinary Success");
        return jsonResponse['secure_url'];
      } else {
        throw Exception("Cloudinary Error: ${response.body}");
      }
    } catch (e) {
      print("❌ Cloudinary Error: $e");
      rethrow;
    }
  }

  // 💾 SAVE PROFILE
  Future<void> saveProfile(String currentImageUrl) async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name is required")));
      return;
    }

    setState(() => isSaving = true);

    try {
      String imageUrl = currentImageUrl;
      
      if (_image != null) {
        imageUrl = await uploadToCloudinary(_image!);
      }

      print("👤 Saving to Firestore...");
      
      // Increased timeout and using server timestamp for both
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        "name": nameController.text.trim(),
        "bio": bioController.text.trim(),
        "imageUrl": imageUrl,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 25), onTimeout: () {
        print("ℹ️ Firestore write timed out, but continuing...");
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated!")));
      setState(() => _image = null); 
      
      // Navigate after a small delay to ensure firestore has a head start
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
      });

    } catch (e) {
      print("🔥 Save Error: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      body: StreamBuilder<DocumentSnapshot>(
        stream: getUserStream(user!.uid),
        builder: (context, snapshot) {
          // Handle initial loading
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          // Handle data
          final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          
          // Pre-fill controllers ONLY if they are empty
          if (nameController.text.isEmpty && userData['name'] != null) {
            nameController.text = userData['name'];
          }
          if (bioController.text.isEmpty && userData['bio'] != null) {
            bioController.text = userData['bio'];
          }

          final String currentImageUrl = userData['imageUrl'] ?? "";

          return Stack(
            children: [
              // 🎨 BACKGROUND
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff0f172a), Color(0xff1e293b)],
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Profile",
                            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: logout,
                            icon: const Icon(Icons.logout, color: Colors.redAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // 📸 PROFILE IMAGE (NO PLACEHOLDER URL)
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor: const Color(0xff1e293b),
                                // ✅ Using local icon fallback instead of via.placeholder.com
                                backgroundImage: _image != null
                                    ? Image.network(_image!.path).image
                                    : (currentImageUrl.isNotEmpty
                                        ? NetworkImage(currentImageUrl)
                                        : null),
                                child: (currentImageUrl.isEmpty && _image == null)
                                    ? const Icon(Icons.person, size: 70, color: Colors.grey)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.blueAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        user?.email ?? "",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                      ),
                      const SizedBox(height: 40),

                      // FORM CARD
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Name"),
                                _buildTextField(nameController, Icons.person, "Enter full name"),
                                const SizedBox(height: 20),
                                _buildLabel("Bio"),
                                _buildTextField(bioController, Icons.article, "Add a bio...", maxLines: 3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : () => saveProfile(currentImageUrl),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Update Profile", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}