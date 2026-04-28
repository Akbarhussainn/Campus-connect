import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'router.dart'; 
import 'screens/profile_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 2. 🔥 Web-Specific Firestore Stability Settings
  // We disable persistence for Web to avoid IndexedDB lock issues on localhost
  // We force Long Polling to bypass potential WebSocket blocks
  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false, 
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      webExperimentalForceLongPolling: true,
    );
  } else {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Connect',    
      builder: (context, child) {
        return Center(
          child: Container(
            width: 390,
            height: 844,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.hardEdge,
            child: child,
          ),
        );
      },
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/auth': (context) => const AuthWrapper(),
        '/dashboard': (context) => const DashboardPage(),
        '/profile': (context) => const ProfileScreen(),
      },
      initialRoute: '/',
    );  
  }
}
