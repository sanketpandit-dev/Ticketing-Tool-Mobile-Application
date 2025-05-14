import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tickteting_tool/Model/otpmodel.dart';

class OtpService {
  final String baseUrl = 'http://taskmgmtapi.alphonsol.com';

  Future<OtpResponse> sendOtp(SendOtpRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        return OtpResponse.fromJson(jsonResponse);
      } else {
        // Handle error responses
        return OtpResponse(
          message: 'Error: ${response.statusCode} - ${response.reasonPhrase}',
          success: false,
        );
      }
    } catch (e) {
      return OtpResponse(
        message: 'Failed to connect to server: $e',
        success: false,
      );
    }
  }
}