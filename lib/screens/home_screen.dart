import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // 🔥 DUMMY USERS ONLY
List<Map<String, dynamic>> users = [];
bool isLoading = true;

  @override
void initState() {
  super.initState();
  fetchUsers();
}
   Future<void> fetchUsers() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    final allUsers = snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['uid'] = doc.id;
          return data;
        })
        //.where((user) => user['uid'] != currentUser.uid)
        .toList();

    setState(() {
      users = List<Map<String, dynamic>>.from(allUsers);
      isLoading = false;
    });

  } catch (e) {
    print("🔥 ERROR: $e");
    setState(() => isLoading = false);
  }
}
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f172a),

      body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : users.isEmpty
        ? const Center(
            child: Text(
              "No users found",
              style: TextStyle(color: Colors.white),
            ),
          )
        : SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Campus Connect",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: CardSwiper(
                cardsCount: users.length,
                numberOfCardsDisplayed: 3,
                backCardOffset: const Offset(0, 40),

                onSwipe: (previousIndex, currentIndex, direction) {
                  final user = users[previousIndex];

                  if (direction == CardSwiperDirection.right) {
                    print("❤️ Liked ${user['name']}");
                  } else {
                    print("❌ Skipped ${user['name']}");
                  }

                  return true;
                },

                cardBuilder: (context, index, percentX, percentY) {
                  final user = users[index];

                  return Stack(
                    children: [

                      // 🔥 CARD
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(
  user['imageUrl'] != null && user['imageUrl'] != ""
      ? user['imageUrl']
      : "https://i.pravatar.cc/400?img=10",
),
                            fit: BoxFit.cover,
                          ),
                        ),

                        // 🔥 OVERLAY
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),

                          // 🔥 USER INFO
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                             Text(
  user['bio'] != null && user['bio'] != ""
      ? user['bio']
      : "No bio yet",
  style: const TextStyle(color: Colors.grey),
)
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ❤️ RIGHT SWIPE
                      Positioned(
                        top: 80,
                        left: 30,
                        child: Opacity(
                          opacity: percentX > 0
                              ? percentX.clamp(0, 1).toDouble()
                              : 0.0,
                          child: Transform.scale(
                            scale:
                                percentX.clamp(0.5, 1.2).toDouble(),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.green,
                              size: 100,
                            ),
                          ),
                        ),
                      ),

                      // ❌ LEFT SWIPE
                      Positioned(
                        top: 80,
                        right: 30,
                        child: Opacity(
                          opacity: percentX < 0
                              ? (-percentX).clamp(0, 1).toDouble()
                              : 0.0,
                          child: Transform.scale(
                            scale: (-percentX)
                                .clamp(0.5, 1.2)
                                .toDouble(),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 100,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}