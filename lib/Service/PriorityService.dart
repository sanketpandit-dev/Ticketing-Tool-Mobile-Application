import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tickteting_tool/Model/PriorityModel.dart';

class PriorityService {
  final String baseUrl = 'http://taskmgmtapi.alphonsol.com/api';

  Future<List<Priority>> getPriorities() async {
    try {
      final url = Uri.parse('$baseUrl/ticket/getPriorities');
      print('Making GET request to: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          print('Parsed JSON data: $jsonData');
          
          if (jsonData.isEmpty) {
            print('Warning: No priorities found');
            return [];
          }

          final priorities = jsonData.map((json) => Priority.fromJson(json)).toList();
          print('Successfully created ${priorities.length} priorities');
          print('Priorities: ${priorities.map((p) => '${p.priorityId}: ${p.priorityName}').join(', ')}');
          return priorities;
        } catch (e) {
          print('Error parsing priority data: $e');
          throw Exception('Failed to parse priority data: $e');
        }
      } else {
        throw Exception('Failed to load priorities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPriorities: $e');
      throw Exception('Failed to load priorities: $e');
    }
  }
} 