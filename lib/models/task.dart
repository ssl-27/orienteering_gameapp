import 'package:orienteering/models/task_type.dart';

class Task {
  final String id;
  final String name;
  final String location;
  final String content;
  final int points;
  final TaskType type;
  final List<String> completedBy;
  final Map<String, dynamic> additionalData;

  Task({
    required this.id,
    required this.location,
    required this.points,
    required this.content,
    required this.completedBy,
    required this.additionalData,
    required this.name,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'points': points,
      'content': content,
      'type': type.toString(),
      'completedBy': completedBy,
      'additionalData': additionalData,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      points: json['points'],
      content: json['content'],
      type: TaskType.values.firstWhere(
            (e) => e.toString() == json['type'],
      ),
      completedBy: List<String>.from(json['completedBy']),
      additionalData: json['additionalData'],
    );
  }
}