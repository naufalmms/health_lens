import 'package:flutter/material.dart';
import 'package:health_lens/applications/assets/i_assets.dart';
import 'package:health_lens/applications/components/button/i_button_component.dart';
import 'package:health_lens/applications/components/image/i_image_component.dart';
import 'package:health_lens/applications/theme/i_colors.dart';
import 'package:provider/provider.dart';
import 'package:health_lens/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<AuthProvider>().signInWithGoogle();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<AuthProvider>().error),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 56),
              child: IImage(
                image: IAssets.imgBannerLogin,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Positioned(
              top: 500,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "HealtLens",
                      style: TextStyle(
                        color: Palette.blueDarkColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 56,
                      ),
                    ),
                    const Text(
                      "Your Friend to Remember",
                      style: TextStyle(
                        color: Palette.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 80.0,
                        left: 16,
                        right: 16,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : IButton(
                              textSize: 20,
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              name: "Sign in with Google",
                              onPressed: () => _handleGoogleSignIn(context),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
