import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // 🔥 DUMMY USERS ONLY
  final List<Map<String, dynamic>> users = [
    {
      "name": "Rahul",
      "email": "rahul@kzu.ac.in",
      "image": "https://i.pravatar.cc/400?img=1"
    },
    {
      "name": "Ankit",
      "email": "ankit@kzu.ac.in",
      "image": "https://i.pravatar.cc/400?img=2"
    },
    {
      "name": "Priya",
      "email": "priya@kzu.ac.in",
      "image": "https://i.pravatar.cc/400?img=3"
    },
    {
      "name": "Neha",
      "email": "neha@kzu.ac.in",
      "image": "https://i.pravatar.cc/400?img=4"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f172a),

      body: SafeArea(
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
                            image: NetworkImage(user['image']),
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
                                  user['email'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
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