import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'game_screen.dart';
import '../models/game.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  bool isLoading = true;
  Game? activeGame;

  @override
  void initState() {
    super.initState();
    _checkExistingGame();
  }

  Future<void> _checkExistingGame() async {
    final prefs = await SharedPreferences.getInstance();
    final gameJson = prefs.getString('current_game');

    if (gameJson != null) {
      final game = Game.fromJson(json.decode(gameJson));
      if (game.isActive) {
        setState(() {
          activeGame = game;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void _navigateToGame(bool isIndoor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(isIndoor: isIndoor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (activeGame != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Active Game Exists'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Active ${activeGame!.isIndoor ? "Indoor" : "Outdoor"} Game',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Game Code: ${activeGame!.gameCode}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _navigateToGame(activeGame!.isIndoor),
                child: const Text('Continue Game'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              onPressed: () => _navigateToGame(true),
              child: const Text('Indoor Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              onPressed: () => _navigateToGame(false),
              child: const Text('Outdoor Game'),
            ),
          ],
        ),
      ),
    );
  }
}