import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Color lightBlueColor = Colors.lightBlue;

    final InputDecoration customInputDecoration = InputDecoration(
      fillColor: Colors.grey[100],
      filled: true,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: lightBlueColor, width: 2.0),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
    );

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo1.png',
                    width: 200,
                  ),
                ),
                const SizedBox(height: 30),


                TextField(
                  controller: _usernameController,
                  cursorColor: lightBlueColor,
                  decoration: customInputDecoration.copyWith(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 16),


                TextField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  cursorColor: lightBlueColor,
                  decoration: customInputDecoration.copyWith(
                    labelText: 'Old Password',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 16),


                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  cursorColor: lightBlueColor,
                  decoration: customInputDecoration.copyWith(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  cursorColor: lightBlueColor,
                  decoration: customInputDecoration.copyWith(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 24),

                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlueColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      // Validate the form
                      if (_usernameController.text.isEmpty ||
                          _oldPasswordController.text.isEmpty ||
                          _newPasswordController.text.isEmpty ||
                          _confirmPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All fields are required')),
                        );
                        return;
                      }

                      // Check if new password and confirm password match
                      if (_newPasswordController.text != _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('New password and confirm password do not match')),
                        );
                        return;
                      }


                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password changed successfully')),
                      );
                    },
                    child: const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Here Button (Text Button)
                TextButton(
                  onPressed: () {
                    // Navigate back to login screen
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 16, color: lightBlueColor),
                      const SizedBox(width: 4),
                      Text(
                        'Login Here',
                        style: TextStyle(
                          color: lightBlueColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

