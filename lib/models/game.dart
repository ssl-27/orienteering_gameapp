import 'task.dart';

class Game {
  final String gameCode;
  final bool isIndoor;
  final List<Task> tasks;
  final bool isActive;

  Game({
    required this.gameCode,
    required this.isIndoor,
    required this.tasks,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameCode': gameCode,
      'isIndoor': isIndoor,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'isActive': isActive,
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      gameCode: json['gameCode'],
      isIndoor: json['isIndoor'],
      tasks: (json['tasks'] as List)
          .map((task) => Task.fromJson(task))
          .toList(),
      isActive: json['isActive'],
    );
  }
}