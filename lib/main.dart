import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart'; // ADD THIS
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'router.dart'; // your router file
import 'screens/profile_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  

  // 🔥 STABILITY FIX: Disable persistence for Web to prevent hangs on localhost
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    webExperimentalForceLongPolling: true,
  );

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
      width: 390,   // 📱 phone width
      height: 844,  // 📱 phone height
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    ),
  );
},

    
    // If you want to see only a particular page, change here (Home_screen/Dashboard etc.), before routes.


      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/auth': (context) => const AuthWrapper(),
        '/dashboard': (context) => const DashboardPage(),// After any changes we have to add here 
        '/profile': (context) => const ProfileScreen(),
      },
      // 👇 Make AuthWrapper the initial screen
      initialRoute: '/',
    );  
  }
}
