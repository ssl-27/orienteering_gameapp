import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orienteering/screens/task_details_screen.dart';
import '../models/task.dart';
import '../service/task.dart';
import 'leader_board_screen.dart';

class UserTasksListScreen extends StatefulWidget {
  final bool isIndoor;
  final String gameCode;
  final String userId;
  const UserTasksListScreen({super.key, required this.isIndoor, required this.gameCode, required this.userId});

  @override
  State<UserTasksListScreen> createState() => _UserTasksListScreenState();
}


class _UserTasksListScreenState extends State<UserTasksListScreen> {
  late TaskService _taskService;
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _taskService = TaskService(gameCode: widget.gameCode);
    _tasksFuture = _taskService.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _tasksFuture = _taskService.getTasks();
              });
            },
          ),
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => LeaderBoardScreen(gameCode: widget.gameCode, userId: widget.userId)));
          }, icon: const Icon(Icons.leaderboard))
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context,snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _tasksFuture = _taskService.getTasks();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No tasks found'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final task = snapshot.data![index];
              return ListTile(
                title: Text("Task: ${task.name}"),
                subtitle: Text("Location: ${task.location}"),
                trailing: task.completedBy.contains(widget.userId) ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.close, color: Colors.red),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(task: task, userId: widget.userId, gameCode: widget.gameCode, isIndoor: widget.isIndoor,),
                    ),
                  );
                },
              );
            },
          );
        }
      )
    );
  }
}