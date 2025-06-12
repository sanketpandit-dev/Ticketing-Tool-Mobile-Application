import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricGate extends StatefulWidget {
  final Widget child;
  const BiometricGate({required this.child, Key? key}) : super(key: key);

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate> with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();
  bool _authInProgress = false;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticateIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _authenticateIfNeeded();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      setState(() {
        _unlocked = false;
      });
    }
  }

  void _authenticateIfNeeded() {
    if (!_unlocked && !_authInProgress) {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _authInProgress = true;
    });
    try {
      final canCheck = await auth.canCheckBiometrics;
      final available = await auth.getAvailableBiometrics();
      if (canCheck && available.isNotEmpty) {
        final authenticated = await auth.authenticate(
          localizedReason: 'Scan your fingerprint to access the app',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
        if (authenticated) {
          setState(() {
            _unlocked = true;
          });
        }
      }
    } catch (e) {
      // Handle error
    }
    setState(() {
      _authInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 