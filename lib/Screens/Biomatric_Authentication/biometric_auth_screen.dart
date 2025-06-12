import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:tickteting_tool/Screens/Biomatric_Authentication/auth_provider.dart';
import 'package:tickteting_tool/Screens/Splashscreen.dart';
import 'package:tickteting_tool/Screens/login/LoginScreen.dart';

class BiometricAuthScreen extends StatefulWidget {
  @override
  _BiometricAuthScreenState createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isBiometricAvailable = false;
  bool _isAuthenticating = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App has come to foreground, trigger authentication
      if (!_isAuthenticating) {
        _checkBiometrics();
      }
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final availableBiometrics = await auth.getAvailableBiometrics();
      
      setState(() {
        _isBiometricAvailable = canCheckBiometrics && availableBiometrics.isNotEmpty;
      });

      if (_isBiometricAvailable) {
        _authenticate();
      } else {
        setState(() {
          _errorMessage = 'Biometric authentication is not available';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking biometrics: $e';
      });
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!mounted) return;

      if (authenticated) {
        _goToSplashScreen();
      } else {
        setState(() {
          _errorMessage = 'Authentication failed. Please try again.';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication error: $e';
        _isAuthenticating = false;
      });
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _goToSplashScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isAuthenticating)
                const CircularProgressIndicator()
              else if (!_isBiometricAvailable)
                Column(
                  children: [
                    const Icon(Icons.fingerprint, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(_errorMessage),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _goToLogin,
                      child: const Text('Go to Login'),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    const Icon(Icons.fingerprint, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'Touch the fingerprint sensor to authenticate',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _authenticate,
                      child: const Text('Authenticate'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text('Use Password Instead'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
