import 'package:flutter/material.dart';
import 'voice_intro_screen.dart';

class WelcomeOnboardingScreen extends StatelessWidget {
  const WelcomeOnboardingScreen({super.key});

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

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Spacer(),

              const Text(
                "Campus Connect",
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Connect through voices before appearances.",
                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 60,

                child: ElevatedButton(
                  onPressed: () {
                       Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => const VoiceIntroScreen(),
                    ),
                  );
                },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ),
    );
  }
}