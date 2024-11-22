import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskService {
  static const String baseUrl = 'http://10.0.2.2:3000';
  final String gameCode;

  TaskService({required this.gameCode});

  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tasks?gameCode=$gameCode'));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  submitTask(id, Map<String, dynamic> taskData, String userId) async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}/tasks/${id}'));
      final userStatusBeforeUpdate = await http.get(Uri.parse('${baseUrl}/users/${userId}'));
      int points = 0;
      if (response.statusCode == 200 && userStatusBeforeUpdate.statusCode == 200) {
        final task = Task.fromJson(json.decode(response.body));
        final user = json.decode(userStatusBeforeUpdate.body);
        task.completedBy.add(userId);
        points = task.points;
        user['score'] += points;
        final userStatusAfterUpdate = await http.put(
          Uri.parse('${baseUrl}/users/${userId}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(user),
        );
        final taskSubmittedResponse = await http.put(
          Uri.parse('${baseUrl}/tasks/${id}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(task.toJson()),
        );


        if (taskSubmittedResponse.statusCode == 200 && userStatusAfterUpdate.statusCode == 200) {
          return true;
        } else {
          throw Exception('Failed to submit task');
        }
      } else {
        throw Exception('Task not found');
      }
    }
    catch (e) {
      throw Exception('Error submitting task: $e');
    }
  }
}