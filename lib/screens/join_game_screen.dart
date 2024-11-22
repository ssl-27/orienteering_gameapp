import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orienteering/screens/user_tasks_list_screen.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final TextEditingController _gameCodeController = TextEditingController();
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = const Uuid().v4();
  }

  @override
  void dispose() {
    _gameCodeController.dispose();
    super.dispose();
  }

  void createUser() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'id': _userId = const Uuid().v4(),
        'gameCode': _gameCodeController.text,
        'score': 0,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Join a game by entering the game code"),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _gameCodeController,
                maxLength: 8,
                decoration: const InputDecoration(
                  labelText: 'Game Code',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final gameCode = _gameCodeController.text;

                try {
                  final response = await http.get(
                    Uri.parse('http://10.0.2.2:3000/gameCodes?gameCode=$gameCode'),
                  );
                  final responseData = json.decode(response.body);
                  final isIndoor = responseData['isIndoor'];
                  if (response.statusCode == 200) {
                    createUser();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserTasksListScreen(
                          isIndoor: isIndoor,
                          gameCode: gameCode,
                          userId: _userId,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Game not found'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('An error occurred: $e'),
                    ),
                  );
                }
              },
              child: const Text('Join Game'),
            ),
          ],
        ),
      ),
    );
  }
}