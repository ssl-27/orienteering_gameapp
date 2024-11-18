// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'create_game_screen.dart';
import 'join_game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Or!enteering!'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Create Game',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGameScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Join Game',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoinGameScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}





