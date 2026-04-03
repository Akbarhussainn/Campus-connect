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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isHovered = false;
  bool loading = false;
  String errorText = '';
  bool showText = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => showText = true);
    });
  }

  // 🔐 EMAIL LOGIN
  void loginUser() async {
    String email = emailController.text.trim();

    if (!email.endsWith("@kzu.ac.in")) {
      setState(() {
        errorText = "Please use your university email (@kzu.ac.in)";
      });
      return;
    }

    setState(() {
      loading = true;
      errorText = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: passwordController.text,
      );

      User user = FirebaseAuth.instance.currentUser!;
      await saveUser(user);

      Navigator.pushReplacementNamed(context, '/home');

    } on FirebaseAuthException catch (e) {

      if (e.code == 'user-not-found' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-login-credentials') {

        setState(() {
          errorText =
              "No account found. Redirecting you to sign up...";
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/register');
          }
        });
      }

      else if (e.code == 'wrong-password') {
        setState(() {
          errorText = "Incorrect password. Please try again.";
        });
      }

      else {
        setState(() {
          errorText = "Login failed. Please try again.";
        });
      }

    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // 🔵 GOOGLE SIGN-IN (FIXED ADDED)
  Future<void> signInWithGoogle() async {
    setState(() {
      loading = true;
      errorText = '';
    });

    try {
      final googleProvider = GoogleAuthProvider();

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);

      String email = userCredential.user!.email!;

      if (!email.endsWith("@kzu.ac.in")) {
        await FirebaseAuth.instance.signOut();

        setState(() {
          errorText =
              "Please use your university email (@kzu.ac.in)";
          loading = false;
        });
        return;
      }

      User user = userCredential.user!;
      await saveUser(user);

      Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      setState(() {
        errorText = "Google sign-in failed. Try again.";
        loading = false;
      });
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

              AnimatedOpacity(
                opacity: showText ? 1 : 0,
                duration: const Duration(milliseconds: 800),
                child: const Column(
                  children: [
                    Text(
                      "Login to your account",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Use your university email to continue",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("University Email"),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Password").copyWith(
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

              const SizedBox(height: 12),

              if (errorText.isNotEmpty)
                Text(
                  errorText,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 20),

              MouseRegion(
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: ElevatedButton(
                  onPressed: loading ? null : loginUser,
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login"),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR", style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),

              const SizedBox(height: 25),

              OutlinedButton(
                onPressed: loading ? null : () => signInWithGoogle(),
                style: OutlinedButton.styleFrom(
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
                        color: Colors.red, size: 30),
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

              const SizedBox(height: 25),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  "New user? Sign up first",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
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