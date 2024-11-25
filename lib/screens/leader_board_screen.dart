import 'package:flutter/material.dart';
import '../models/user.dart';
import '../service/user.dart';

class LeaderBoardScreen extends StatefulWidget {
  final String gameCode;

  const LeaderBoardScreen({Key? key, required this.gameCode}) : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderBoardScreen> {
  late Future<List<User>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = UserService(gameCode: widget.gameCode).getUsersByGameCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: FutureBuilder<List<User>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scores available'));
          } else {
            List<User> scores = snapshot.data!;
            scores.sort((a, b) => b.score.compareTo(a.score)); // Sort by score descending

            return ListView.builder(
              itemCount: scores.length,
              itemBuilder: (context, index) {
                User userScore = scores[index];
                return ListTile(
                  leading: Text('#${index + 1}'),
                  title: Text('User: ${userScore.id}'),
                  trailing: Text('${userScore.score} points'),
                );
              },
            );
          }
        },
      ),
    );
  }
}