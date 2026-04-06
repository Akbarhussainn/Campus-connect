import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> saveUser(User user) async {
  final userRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

  final doc = await userRef.get();

  if (!doc.exists) {
    await userRef.set({
      "uid": user.uid,
      "email": user.email,
      "name": user.email!.split('@')[0],
      "createdAt": Timestamp.now(),
    });
  }
}
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String errorText = '';

  bool obscurePassword = true; // 👁️ toggle
  bool isHovered = false; // 🔵 hover effect

  // 🔐 EMAIL SIGNUP
  void registerUser() async {
  String email = emailController.text.trim();

  if (!email.endsWith("@kzu.ac.in")) {
    setState(() {
      errorText = "Use university email";
    });
    return;
  }

  setState(() {
    loading = true;
    errorText = '';
  });

  try {
    // 🔥 CREATE AUTH USER
    UserCredential cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: passwordController.text,
    );

    User user = cred.user!;

    print("✅ Auth created");

    // 🚀 NAVIGATE IMMEDIATELY
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');

    // 🔥 SAVE USER IN BACKGROUND (DON'T BLOCK UI)
    saveUser(user).catchError((e) {
      print("Firestore error: $e");
    });

  } on FirebaseAuthException catch (e) {
  print("REGISTER ERROR: ${e.code}");

  switch (e.code) {
    case 'email-already-in-use':
      errorText = "Account already exists. Please login";
      break;

    case 'weak-password':
      errorText = "Password should be at least 6 characters";
      break;

    case 'invalid-email':
      errorText = "Invalid email format";
      break;

    case 'network-request-failed':
      errorText = "Check your internet connection";
      break;

    default:
      errorText = "Signup failed. Try again";
  }

  setState(() {});
}}
  // 🔵 GOOGLE SIGN-IN
  
 Future<void> signInWithGoogle() async {
  setState(() {
    loading = true;
    errorText = '';
  });

  try {
    // 🔥 FORCE ACCOUNT SELECTION
    final googleProvider = GoogleAuthProvider()
      ..setCustomParameters({
        'prompt': 'select_account',
      });

    // 🔥 CLEAR OLD SESSION (VERY IMPORTANT)
    await FirebaseAuth.instance.signOut();

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);

    User user = userCredential.user!;
    String email = user.email!.toLowerCase().trim();

    // 🚫 DOMAIN CHECK
    if (!email.endsWith("@kzu.ac.in")) {
      await FirebaseAuth.instance.signOut();

      setState(() {
        errorText = "Use your university email (@kzu.ac.in)";
      });
      return;
    }

    print("✅ GOOGLE REGISTER SUCCESS");

    if (!mounted) return;

    // 🚀 NAVIGATE IMMEDIATELY
    Navigator.pushReplacementNamed(context, '/dashboard');

    // 🔥 SAVE USER IN BACKGROUND
    saveUser(user).catchError((e) {
      print("Firestore error: $e");
    });

  } catch (e) {
    print("GOOGLE REGISTER ERROR: $e");

    setState(() {
      errorText = "Google sign-up cancelled or failed";
    });
  } finally {
    if (mounted) setState(() => loading = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const Text(
                "Create your account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // 📧 EMAIL FIELD
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "University Email",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xff1e293b),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🔒 PASSWORD FIELD WITH EYE
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xff1e293b),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ❌ ERROR TEXT
              if (errorText.isNotEmpty)
                Text(
                  errorText,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 16),

              // 🔵 SIGN UP BUTTON (HOVER DARK)
              
              MouseRegion(
                onEnter: (_) {
                  setState(() => isHovered = true);
                },
                onExit: (_) {
                  setState(() => isHovered = false);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  child: ElevatedButton(
                    onPressed: loading ? null : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHovered
                          ? const Color(0xff2563eb)
                          : const Color(0xff3b82f6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "OR",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),
              

              // 🟢 GOOGLE BUTTON
              ElevatedButton(
                onPressed: loading ? null : signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.g_mobiledata,
                        color: Colors.red, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "Continue with Google",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔁 LOGIN REDIRECT
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}