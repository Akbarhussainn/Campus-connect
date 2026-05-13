import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState
    extends State<ProfileSetupScreen> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController ageController =
      TextEditingController();

  final TextEditingController bioController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F0F),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: SizedBox(
            height: MediaQuery.of(context).size.height,

             child: SingleChildScrollView(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 40),

                  const Text(
                    "Create Your Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Tell others about yourself.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 40),

                  _buildTextField("Your Name", controller: nameController, ),

                  const SizedBox(height: 20),

                  _buildTextField("Age", controller: ageController, ),

                  const SizedBox(height: 20),

                  _buildTextField("Bio", maxLines: 4, controller: bioController),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 60,

                    child: ElevatedButton(

onPressed: () async {

  print("BUTTON CLICKED");

  try {

    print("STARTING FIRESTORE");

    await FirebaseFirestore.instance.collection('users').add({

      'name': nameController.text,
      'age': ageController.text,
      'bio': bioController.text,
      'createdAt': Timestamp.now(),

    })
      .timeout(const Duration(seconds: 10));

    print("SUCCESSFULLY SAVED");

  } catch (e) {

    print("FIREBASE ERROR:");
    print(e.toString());

  }

},

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      child: const Text(
                        "Finish",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    int maxLines = 1,
    required TextEditingController controller, }) 

  {
    return TextField(
      controller: controller,
      maxLines: maxLines,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),

        filled: true,
        fillColor: Colors.white10,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}