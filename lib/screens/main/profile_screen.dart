// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/custom_button.dart';

// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final user = context.watch<AuthProvider>().user;

//     return Scaffold(
//       appBar: AppBar(title: Text('Profile')),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 50,
//               child: Icon(Icons.person, size: 50),
//             ),
//             SizedBox(height: 16),
//             Text(
//               user?.email ?? '',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 32),
//             CustomButton(
//               text: 'Logout',
//               onPressed: () async {
//                 await context.read<AuthProvider>().signOut();
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
import 'package:health_lens/applications/components/dialog/i_dialog.dart';
import 'package:provider/provider.dart';
import 'package:health_lens/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void showDialogLogout(AuthProvider authProvider) async {
      IDialog.instance.info(
        context,
        description: "Apakah Anda Yakin Ingin Keluar ?",
        title: "Keluar",
        image: IAssets.imgBannerLogin,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                IButton(
                  textSize: 20,
                  height: 50,
                  name: "Tidak",
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(context);
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                IButton(
                  textSize: 20,
                  height: 50,
                  name: "Keluar",
                  isOutlined: true,
                  onPressed: () {
                    authProvider.signOut();
                    Navigator.of(context, rootNavigator: true).pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          if (user == null) return const SizedBox();

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user.photoURL ?? ''),
                ),
                const SizedBox(height: 20),
                Text(
                  user.displayName ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(user.email ?? ''),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: IButton(
                    name: "Logout",
                    textSize: 20,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    onPressed: () {
                      // authProvider.signOut();
                      showDialogLogout(authProvider);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
