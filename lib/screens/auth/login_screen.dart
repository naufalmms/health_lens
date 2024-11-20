// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_text_field.dart';

// class LoginScreen extends StatelessWidget {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CustomTextField(
//               controller: _emailController,
//               hintText: 'Email',
//               keyboardType: TextInputType.emailAddress,
//             ),
//             SizedBox(height: 16),
//             CustomTextField(
//               controller: _passwordController,
//               hintText: 'Password',
//               isPassword: true,
//             ),
//             SizedBox(height: 24),
//             CustomButton(
//               text: 'Login',
//               onPressed: () async {
//                 try {
//                   await context.read<AuthProvider>().signIn(
//                         _emailController.text,
//                         _passwordController.text,
//                       );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text(e.toString())),
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:health_lens/applications/assets/i_assets.dart';
import 'package:health_lens/applications/components/button/i_button_component.dart';
import 'package:health_lens/applications/components/image/i_image_component.dart';
import 'package:health_lens/applications/theme/i_colors.dart';
import 'package:provider/provider.dart';
import 'package:health_lens/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                      child: IButton(
                        textSize: 20,
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        name: "Sign in with Google",
                        onPressed: () {
                          context.read<AuthProvider>().signInWithGoogle();
                        },
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
