import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int _previousIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const MatchesScreen(),
    const ChatsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
  setState(() {
    _previousIndex = _selectedIndex; // ✅ store old index
    _selectedIndex = index;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f172a),

      // 🔥 ANIMATED BODY
     body: AnimatedSwitcher(
  duration: const Duration(milliseconds: 350),
  transitionBuilder: (child, animation) {
    final isForward = _selectedIndex > _previousIndex;

    final offsetAnimation = Tween<Offset>(
      begin: Offset(isForward ? 1 : -1, 0), // 👉 correct direction
      end: Offset.zero,
    ).animate(animation);

    return ClipRect(
      child: SlideTransition(
        position: offsetAnimation,
        child: child,
      ),
    );
  },
  child: Container(
    key: ValueKey<int>(_selectedIndex),
    child: _pages[_selectedIndex],
  ),
),

      // 🔻 NAV BAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xff1e293b),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xff1e293b),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Matches",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: "Chats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}

// 🔥 SCREENS

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "❤️ Matches",
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }
}

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "💬 Chats",
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }
}

