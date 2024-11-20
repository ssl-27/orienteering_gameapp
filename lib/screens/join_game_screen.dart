import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});


  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final TextEditingController _gameCodeController = TextEditingController();

  @override
  void dispose() {
    _gameCodeController.dispose();
    super.dispose();
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
            Padding(padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _gameCodeController,
                maxLength: 8,
                decoration: const InputDecoration(
                  labelText: 'Game Code',
                ),
              ),
            ),
            ElevatedButton(onPressed: ()
                async {
                  final gameCode = _gameCodeController.text;
                  final response = await http.get(
                    Uri.parse('https://10.0.2.2:3000/gameCodes?gameCode=$gameCode')
                  );
                  if (response.statusCode == 200) {
                    Navigator.pushNamed(context, '/game', arguments: gameCode);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Game not found'),
                      ),
                    );
                  }
                }, child: const Text('Join Game')),
          ],
        ),
      ),
    );
  }
}