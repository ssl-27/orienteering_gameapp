class User{
  final String id;
  final String gameCode;
  final int score;

  User({required this.id, required this.gameCode, required this.score});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      gameCode: json['gameCode'],
      score: json['score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameCode': gameCode,
      'score': score,
    };
  }
}