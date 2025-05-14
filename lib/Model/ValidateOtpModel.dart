// lib/models/otp_validation_models.dart

class OtpValidationRequest {
  final String username;
  final String userMailId;
  final String otpCode;

  OtpValidationRequest({
    required this.username,
    required this.userMailId,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'userMailId': userMailId,
      'otpCode': otpCode,
    };
  }
}

class OtpValidationResponse {
  final String message;
  final bool isValid;

  OtpValidationResponse({
    required this.message,
    required this.isValid,
  });

  factory OtpValidationResponse.fromJson(dynamic json) {
    // If the response is just a string
    if (json is String) {
      return OtpValidationResponse(
        message: json,
        isValid: json == "OTP is valid.",
      );
    }


    else if (json is Map<String, dynamic>) {
      String message = json['message'] ?? 'Unknown response';
      return OtpValidationResponse(
        message: message,
        isValid: message == "OTP is valid.",
      );
    }

    // Fallback for other types
    return OtpValidationResponse(
      message: json.toString(),
      isValid: json.toString() == "OTP is valid.",
    );
  }
}