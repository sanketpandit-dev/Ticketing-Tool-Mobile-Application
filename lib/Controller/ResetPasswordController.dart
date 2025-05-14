import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tickteting_tool/Model/ResetPasswordModel.dart';

class ResetPasswordController {
  Future<Map<String, dynamic>> resetPassword(ResetPasswordRequest request) async {
    final url = Uri.parse('http://taskmgmtapi.alphonsol.com/api/ResetPassword');

    print('🔐 Reset Password Request URL: $url');
    print('📤 Request Body: ${jsonEncode(request.toJson())}');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    print('📥 Response Status Code: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to reset password: ${response.body}");
    }
  }
}
