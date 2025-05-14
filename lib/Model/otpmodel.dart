class SendOtpRequest {
  final String username;
  final String userMailId;
  final String? createdBy;

  SendOtpRequest({
    required this.username,
    required this.userMailId,
    this.createdBy = 'mobile_app',
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'userMailId': userMailId,
      'createdBy': createdBy,
    };
  }
}

class OtpResponse {
  final String message;
  final String? otp;
  final bool success;

  OtpResponse({
    required this.message,
    this.otp,
    required this.success,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      message: json['message'] ?? 'No message provided',
      otp: json['otp'],
      success: json['message'] != null && json['message'].toString().contains('successfully'),
    );
  }
}