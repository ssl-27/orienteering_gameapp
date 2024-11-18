// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';
import '../models/game.dart';
import '../models/task.dart';

class GameScreen extends StatefulWidget {
  final bool isIndoor;

  const GameScreen({super.key, required this.isIndoor});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String? gameCode;
  List<Task> tasks = [];
  late SharedPreferences prefs;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    prefs = await SharedPreferences.getInstance();
    final existingGame = await _loadGameState();

    if (existingGame != null && existingGame.isActive) {
      // If there's an active game and it matches the current game type (indoor/outdoor)
      if (existingGame.isIndoor == widget.isIndoor) {
        setState(() {
          gameCode = existingGame.gameCode;
          tasks = existingGame.tasks;
          isLoading = false;
        });
      } else {
        // If game types don't match, show error and go back
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'An active ${existingGame.isIndoor ? "indoor" : "outdoor"} game already exists!'
              ),
            ),
          );
        }
      }
    } else {
      // Create new game if no active game exists
      setState(() {
        gameCode = _generateGameCode();
        _saveGameState();
        isLoading = false;
      });
    }
  }

  String _generateGameCode() {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<Game?> _loadGameState() async {
    final gameJson = prefs.getString('current_game');
    if (gameJson != null) {
      return Game.fromJson(json.decode(gameJson));
    }
    return null;
  }

  Future<void> _saveGameState() async {
    if (gameCode != null) {
      final game = Game(
        gameCode: gameCode!,
        isIndoor: widget.isIndoor,
        tasks: tasks,
      );
      await prefs.setString('current_game', json.encode(game.toJson()));
    }
  }

  void _showEndGameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Game'),
          content: const Text('Are you sure you want to end this game?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('End Game'),
              onPressed: () async {
                await prefs.remove('current_game');
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
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

    if (gameCode == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error initializing game'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isIndoor ? 'Indoor Game' : 'Outdoor Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement task creation
            },
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _showEndGameDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Game Code: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  gameCode!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text(task.location),
                    subtitle: Text(task.description),
                    trailing: Text(
                      '${task.points} pts',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      // TODO: Implement task detail view
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}