import 'package:flutter/material.dart';
import 'package:health_lens/screens/auth/registration_screen.dart';
import 'package:provider/provider.dart';
import 'package:health_lens/screens/auth/login_screen.dart';
import 'package:health_lens/screens/main/main_screen.dart';
import 'package:health_lens/providers/auth_provider.dart';
import 'package:health_lens/applications/theme/i_colors.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const Scaffold(
        backgroundColor: Palette.primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlutterLogo(size: 100),
              SizedBox(height: 20),
              Text(
                'HealthLens',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading indicator while determining auth state
        if (authProvider.status == AuthStatus.uninitialized) {
          return const Scaffold(
            backgroundColor: Palette.primaryColor,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        // Route to appropriate screen based on auth status
        switch (authProvider.status) {
          case AuthStatus.authenticated:
            return const MainScreen();
          case AuthStatus.registering:
            return const RegistrationScreen();
          case AuthStatus.unauthenticated:
          default:
            return const LoginScreen();
        }
      },
    );
  }
}
