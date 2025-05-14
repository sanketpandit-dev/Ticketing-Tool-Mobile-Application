import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tickteting_tool/Model/ValidateOtpModel.dart';
import 'package:tickteting_tool/Service/ValidateOtpService.dart';

class OtpVerificationController {
  final OtpValidationService _validationService = OtpValidationService();
  Timer? _resendTimer;

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<int> resendSeconds = ValueNotifier<int>(60);
  ValueNotifier<bool> canResend = ValueNotifier<bool>(false);

  // OTP verification
  Future<OtpValidationResponse> validateOtp({
    required String username,
    required String email,
    required String otpCode,
  }) async {
    try {
      isLoading.value = true;

      // Validate inputs
      if (username.isEmpty || email.isEmpty || otpCode.isEmpty) {
        return OtpValidationResponse(
          message: 'All fields are required',
          isValid: false,
        );
      }

      if (otpCode.length != 6) {
        return OtpValidationResponse(
          message: 'Please enter complete 6-digit OTP',
          isValid: false,
        );
      }

      // Create request model
      final request = OtpValidationRequest(
        username: username,
        userMailId: email,
        otpCode: otpCode,
      );

      // Call API service
      final response = await _validationService.validateOtp(request);
      return response;

    } catch (e) {
      return OtpValidationResponse(
        message: 'Error: $e',
        isValid: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend timer management
  void startResendTimer() {
    // Cancel any existing timer
    _resendTimer?.cancel();

    canResend.value = false;
    resendSeconds.value = 60;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  // Function to handle resend OTP
  Future<void> resendOtp({
    required String username,
    required String email,
    required Function(String) onResendComplete,
  }) async {
    if (!canResend.value) return;

    // Reset timer
    startResendTimer();

    // Here you'd typically call your send OTP API again
    // This would be the same API called from the previous screen
    // For now, we'll just simulate a successful response

    // Call the onResendComplete callback with a message
    onResendComplete('OTP has been resent');
  }

  // Cleanup method to be called when the controller is no longer needed
  void dispose() {
    _resendTimer?.cancel();
    _resendTimer = null;
    isLoading.dispose();
    resendSeconds.dispose();
    canResend.dispose();
  }
}