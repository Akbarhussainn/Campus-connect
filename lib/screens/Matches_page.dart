import 'package:flutter/material.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {

  List<Map<String, String>> pending = [
    {"name": "Rahul"},
    {"name": "Priya"},
  ];

  List<Map<String, String>> matches = [
    {"name": "Aman"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connections"),
        centerTitle: true,
      ),
      body: ListView(
        children: [

          // 🔵 Pending Title
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Pending Connections",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // 🔵 Pending List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pending.length,
            itemBuilder: (context, index) {
              var user = pending[index];

              return ListTile(
                title: Text(user["name"]!),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ✅ CONNECT BUTTON
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          var selectedUser = pending[index];
                          pending.removeAt(index);
                          matches.add(selectedUser);
                        });
                      },
                      child: const Text("Connect Back"),
                    ),

                    const SizedBox(width: 8),

                    // ❌ REJECT BUTTON
                    IconButton(
                      onPressed: () {
                        setState(() {
                          pending.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          ),

          // 🟢 Matches Title
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Your Matches",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // 🟢 Matches Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              var user = matches[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    user["name"]!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}