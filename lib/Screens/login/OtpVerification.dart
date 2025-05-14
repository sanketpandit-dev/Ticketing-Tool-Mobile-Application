import 'package:flutter/material.dart';
import 'package:tickteting_tool/Controller/validateotpcontroller.dart';
import 'package:tickteting_tool/Screens/login/ForgetPassword.dart';
import 'package:tickteting_tool/Screens/login/ResetPassword.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String username;

  const OtpVerificationScreen({
    Key? key,
    required this.email,
    required this.username,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final OtpVerificationController _controller = OtpVerificationController();

  bool _isLoading = false;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();


    for (int i = 0; i < 5; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.isNotEmpty) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }

    _controller.isLoading.addListener(_handleLoadingChange);
    _controller.resendSeconds.addListener(_handleResendSecondsChange);
    _controller.canResend.addListener(_handleCanResendChange);
    _controller.startResendTimer();
  }

  void _handleLoadingChange() {
    if (mounted) {
      setState(() {
        _isLoading = _controller.isLoading.value;
      });
    }
  }

  void _handleResendSecondsChange() {
    if (mounted) {
      setState(() {
        _resendSeconds = _controller.resendSeconds.value;
      });
    }
  }

  void _handleCanResendChange() {
    if (mounted) {
      setState(() {
        _canResend = _controller.canResend.value;
      });
    }
  }

  void _resendOtp() {
    if (!_canResend) return;

    // Clear all OTP fields
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    // Call controller to handle resend
    _controller.resendOtp(
      username: widget.username,
      email: widget.email,
      onResendComplete: (message) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message))
          );
        }
      },
    );
  }

  String _getCompleteOtp() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _verifyOtp() async {
    final otp = _getCompleteOtp();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      
      // Call the controller to validate OTP
      final response = await _controller.validateOtp(
        username: widget.username,
        email: widget.email,
        otpCode: otp,
      );

      if (!mounted) return;

      // Display the response message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );

      // If valid, navigate to reset password screen
      if (response.isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: widget.email,
              username: widget.username,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Center(child: Image.asset('assets/images/logo1.png', width: 200)),
            const SizedBox(height: 30),

            // Title
            const Text(
              'Verify OTP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Instructions
            Text(
              'Enter the 6-digit code sent to ${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // OTP Input Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 40,
                  height: 50,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    cursorColor: AppStyles.primaryColor,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: InputDecoration(
                      fillColor: AppStyles.fillColor,
                      filled: true,
                      counterText: "",
                      contentPadding: EdgeInsets.zero,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppStyles.primaryColor,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Resend OTP option
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Didn't receive code? ",
                  style: TextStyle(color: Colors.grey),
                ),
                GestureDetector(
                  onTap: _canResend ? _resendOtp : null,
                  child: Text(
                    _canResend ? "Resend" : "Resend in $_resendSeconds s",
                    style: TextStyle(
                      color: _canResend ? AppStyles.primaryColor : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppStyles.primaryButtonStyle,
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Verify',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {

    _controller.isLoading.removeListener(_handleLoadingChange);
    _controller.resendSeconds.removeListener(_handleResendSecondsChange);
    _controller.canResend.removeListener(_handleCanResendChange);

    // Dispose controllers and focus nodes
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }


    _controller.dispose();

    super.dispose();
  }
}
