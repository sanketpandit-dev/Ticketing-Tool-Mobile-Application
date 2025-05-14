import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tickteting_tool/Controller/ResetPasswordController.dart';
import 'package:tickteting_tool/Model/ResetPasswordModel.dart';
import 'package:tickteting_tool/Screens/login/ForgetPassword.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String username;

  const ResetPasswordScreen({super.key, required this.email, required this.username});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  void _resetPassword() async {
    if (!_isValidPassword(_newPasswordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final controller = ResetPasswordController();

    try {
      final result = await controller.resetPassword(ResetPasswordRequest(

        username: widget.username,
        newPassword: _newPasswordController.text,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['remark'])),
      );

      if (result['result'] == 1) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reset password')),
      );
    }

    setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF3B82F6),
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.all(16),

              color: Color(0xFF3B82F6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: const [
                  SizedBox(height: 16),
                  Text(
                    'Reset Your Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter Your New Password And Confirm ',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Instructions
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Column(
                    children: [

                      Text(
                        'Create a new password for ${widget.email}',

                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 30),


                      // New Password Field
                      TextField(
                        controller: _newPasswordController,
                        obscureText: !_showPassword,
                        cursorColor: AppStyles.primaryColor,
                        decoration: AppStyles.getInputDecoration(
                          label: 'New Password',
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_showPassword,
                        cursorColor: AppStyles.primaryColor,
                        decoration: AppStyles.getInputDecoration(
                          label: 'Confirm Password',
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Password requirements
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password must be at least 8 characters',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Reset Password Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppStyles.primaryButtonStyle,
                          onPressed: _isLoading ? null : _resetPassword,
                          child:
                          _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Reset Password',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
