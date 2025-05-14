import 'package:flutter/material.dart';
import 'package:tickteting_tool/Model/otpmodel.dart';
import 'package:tickteting_tool/Service/OtpService.dart';


class ForgetPasswordController {
  final OtpService _otpService = OtpService();

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<OtpResponse> sendOtp({
    required String username,
    required String email,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;

      // Validate inputs
      if (username.isEmpty || email.isEmpty) {
        return OtpResponse(
            message: 'Username and email are required',
            success: false
        );
      }


      final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
      if (!emailRegExp.hasMatch(email)) {
        return OtpResponse(
            message: 'Please enter a valid email address',
            success: false
        );
      }

      // Create request model
      final request = SendOtpRequest(
        username: username,
        userMailId: email,
      );

      // Call API service
      final response = await _otpService.sendOtp(request);
      return response;

    } catch (e) {
      return OtpResponse(
          message: 'Error: $e',
          success: false
      );
    } finally {
      isLoading.value = false;
    }
  }
}