import 'dart:convert';
import 'package:http/http.dart' as http;


import '../models/user.dart';
class UserService {
  static const String baseUrl = 'http://10.0.2.2:3000';
  final String gameCode;

  UserService({required this.gameCode});

  Future<List<User>> getUsersByGameCode() async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/users?gameCode=$gameCode'));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}