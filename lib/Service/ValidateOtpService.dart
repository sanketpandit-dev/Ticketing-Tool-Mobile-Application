import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tickteting_tool/Model/ValidateOtpModel.dart';

class OtpValidationService {
  final String baseUrl = 'http://taskmgmtapi.alphonsol.com';

  Future<OtpValidationResponse> validateOtp(OtpValidationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/validate-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      // Handle empty response
      if (response.body.isEmpty) {
        return OtpValidationResponse(
          message: 'Empty response from server',
          isValid: false,
        );
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        // If not JSON, treat as plain text
        return OtpValidationResponse(
          message: response.body,
          isValid: response.body.toLowerCase().contains('valid'),
        );
      }

      // Handle successful response
      if (response.statusCode == 200) {
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] ?? 'Unknown response';
          return OtpValidationResponse(
            message: message,
            isValid: message.toLowerCase().contains('valid'),
          );
        } else if (responseData is String) {
          return OtpValidationResponse(
            message: responseData,
            isValid: responseData.toLowerCase().contains('valid'),
          );
        }
      }

      // Handle error responses
      String errorMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['message'] ??
            responseData['error'] ??
            'Unknown error occurred';
      } else {
        errorMessage = responseData.toString();
      }

      return OtpValidationResponse(
        message: errorMessage,
        isValid: false,
      );
    } catch (e) {
      return OtpValidationResponse(
        message: 'Failed to connect to server: ${e.toString()}',
        isValid: false,
      );
    }
  }
}