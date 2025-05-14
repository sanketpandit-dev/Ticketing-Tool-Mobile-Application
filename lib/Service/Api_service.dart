import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tickteting_tool/Model/Login_Request.dart';
import 'package:tickteting_tool/Model/Login_Response.dart';


class ApiService {
  static const String baseUrl = 'http://taskmgmtapi.alphonsol.com/api';

  Future<Map<String, dynamic>> login(LoginRequest loginRequest) async {
    try {
      print('Sending login request: ${loginRequest.toJson()}');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginRequest.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);


        final result = responseData['Result'] ??
            responseData['result'] ??
            responseData['status'];

        if (result?.toString().toLowerCase() == 'success') {
          return {
            'success': true,
            'data': responseData
          };
        } else {
          return {
            'success': false,
            'message': responseData['Remark'] ??
                responseData['message'] ??
                'Login failed'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error in login: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }
}