import 'package:flutter/material.dart';
import 'home_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // Pages for each tab
  final List<Widget> _pages = [
    HomeScreen(),  
    const Center(child: Text("🏠 Home Screen", style: TextStyle(fontSize: 20))),
    const Center(child: Text("❤️ Matches Screen", style: TextStyle(fontSize: 20))),
    const Center(child: Text("💬 Chats Screen", style: TextStyle(fontSize: 20))),
    const Center(child: Text("👤 Profile Screen", style: TextStyle(fontSize: 20))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Connect"),
        centerTitle: true,
      ),

      body: _pages[_selectedIndex],

      // 🔥 Bottom Navigation (Instagram style)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // 🏠
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite), // ❤️
            label: "Matches",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat), // 💬
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // 👤
            label: "Profile",
          ),
        ],
      ),
    );
  }
}