import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tickteting_tool/Model/DepartmentModel.dart';

class DepartmentService {
  final String baseUrl = 'http://taskmgmtapi.alphonsol.com/api';

  Future<List<Department>> getDepartments() async {
    try {
      print('Making API request to: $baseUrl/department/get');
      final response = await http.get(
        Uri.parse('$baseUrl/department/get'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('Parsed JSON data: $jsonData');
        
        try {
          final departments = jsonData.map((json) {
            print('Processing department data: $json');
            return Department.fromJson(json);
          }).toList();
          
          print('Created departments: ${departments.map((d) => '${d.departmentId}: ${d.departmentName}').join(', ')}');
          return departments;
        } catch (e) {
          print('Error parsing department data: $e');
          throw Exception('Failed to parse department data: $e');
        }
      } else {
        throw Exception('Failed to load departments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getDepartments: $e');
      throw Exception('Failed to load departments: $e');
    }
  }
} 