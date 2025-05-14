
import 'package:flutter/material.dart';
import 'package:tickteting_tool/Controller/otpcontroller.dart';
import 'package:tickteting_tool/Screens/login/OtpVerification.dart';

class AppStyles {
  static const Color primaryColor = Color(0xFF3B82F6);
  static final Color fillColor = Colors.white;

  static InputDecoration getInputDecoration({required String label}) {
    return InputDecoration(
      fillColor: fillColor,
      filled: true,
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2.0),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
    );
  }

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF3B82F6),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );
}

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final ForgetPasswordController _controller = ForgetPasswordController();

  bool _isLoading = false;

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  void _sendOTP() async {
    setState(() => _isLoading = true);

    final response = await _controller.sendOtp(
      username: _usernameController.text,
      email: _emailController.text,
      context: context,
    );

    setState(() => _isLoading = false);

    // Show message to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );

    // If successful, navigate to OTP verification screen
    if (response.success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            email: _emailController.text,
            username: _usernameController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF3B82F6),
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                color:Color(0xFF3B82F6),
                child: const Column(
                  children: [
                    SizedBox(height: 16),
                    Text(
                      'Reset Your Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enter your email to receive OTP and reset your password.',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 19),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            TextField(
                              controller: _usernameController,
                              cursorColor: AppStyles.primaryColor,
                              decoration: AppStyles.getInputDecoration(
                                label: 'User Name',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: AppStyles.primaryColor,
                              decoration: AppStyles.getInputDecoration(
                                label: 'Email Address',
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Send OTP Button
                            SizedBox(
                              width: double.infinity,

                              child: ElevatedButton(
                                style: AppStyles.primaryButtonStyle,

                                onPressed: _isLoading ? null : _sendOTP,
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
                                  'Send OTP',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.arrow_back,
                                    size: 16,
                                    color: Color(0xFF3B82F6),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Back to Login',
                                    style: TextStyle(
                                      color: AppStyles.primaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}