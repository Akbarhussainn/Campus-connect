import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
bool obscurePassword = true;
bool isHovered = false;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String errorText = '';
  bool showText = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        showText = true;
      });
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

      Navigator.pushReplacementNamed(context, '/home');

    } on FirebaseAuthException catch (e) {
      setState(() {
        errorText = e.message ?? "Login failed";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // 🔵 GOOGLE SIGN-IN
  Future<void> signInWithGoogle() async {
    setState(() {
      loading = true;
      errorText = '';
    });

    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);

      String email = userCredential.user!.email!;

      if (!email.endsWith("@kzu.ac.in")) {
        await FirebaseAuth.instance.signOut();

        setState(() {
          errorText =
              "Please sign in using your official university email (@kzu.ac.in)";
          loading = false;
        });
        return;
      }

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

              AnimatedSlide(
                offset: showText ? Offset.zero : const Offset(0, -0.2),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: showText ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: const [
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
              ),

              const SizedBox(height: 30),

              // 📧 Email
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

              // 🔒 Password
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

    // 👁️ Eye icon
    suffixIcon: IconButton(
      icon: Icon(
        obscurePassword ? Icons.visibility_off : Icons.visibility,
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

              // 🟢 LOGIN BUTTON
               // add at top

MouseRegion(
  onEnter: (_) {
    setState(() => isHovered = true);
  },
  onExit: (_) {
    setState(() => isHovered = false);
  },
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      boxShadow: isHovered
          ? [
              BoxShadow(
                color: Colors.blue.withOpacity(0.6),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ]
          : [],
    ),
    child: ElevatedButton(
      onPressed: loading ? null : loginUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff3b82f6),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: loading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Login"),
    ),
  ),
),

              // 🔵 GOOGLE BUTTON
              ElevatedButton.icon(
                onPressed: loading ? null : signInWithGoogle,
                icon: const Icon(Icons.login, color: Colors.black),
                label: const Text(
                  "Continue with Google",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
                const SizedBox(height: 20),

TextButton(
  onPressed: () {
    Navigator.pushNamed(context, '/register');
  },
  child: const Text(
    "New user? Sign up first",
    style: TextStyle(
      color: Colors.grey,
      fontSize: 14,
    ),
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}