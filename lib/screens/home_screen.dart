import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> users = [
      {
        "name": "Aisha",
        "image": "https://i.pravatar.cc/400?img=1"
      },
      {
        "name": "Riya",
        "image": "https://i.pravatar.cc/400?img=2"
      },
      {
        "name": "Ankit",
        "image": "https://i.pravatar.cc/400?img=3"
      },
      {
        "name": "Rahul",
        "image": "https://i.pravatar.cc/400?img=4"
      },
    ];

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
                onSwipe: (previousIndex, currentIndex, direction) {
                  if (direction == CardSwiperDirection.right) {
                    print("Liked ${users[previousIndex]['name']}");
                  } else if (direction == CardSwiperDirection.left) {
                    print("Skipped ${users[previousIndex]['name']}");
                  }
                  return true;
                },
                cardBuilder: (context, index, percentX, percentY) {
                  final user = users[index];

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(user["image"]!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            user["name"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}