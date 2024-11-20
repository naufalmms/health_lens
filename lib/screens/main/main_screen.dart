import 'package:flutter/material.dart';
import 'package:health_lens/applications/theme/i_colors.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:health_lens/screens/main/home_screen.dart';
import 'package:health_lens/screens/main/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    navBarsItems() => [
          PersistentTabConfig(
            screen: const HomeScreen(),
            item: ItemConfig(
              icon: const Icon(Icons.home),
              inactiveIcon: const ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcATop,
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Icon(Icons.home),
                ),
              ),
              title: "Home",
              textStyle: const TextStyle(
                fontSize: 12,
              ),
              activeForegroundColor: Palette.primaryColor,
              inactiveForegroundColor: Colors.grey,
            ),
          ),
          PersistentTabConfig(
            screen: const ProfileScreen(),
            item: ItemConfig(
              icon: const Icon(Icons.person),
              inactiveIcon: const ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcATop,
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Icon(Icons.person),
                ),
              ),
              title: "Profile",
              textStyle: const TextStyle(
                fontSize: 12,
              ),
              activeForegroundColor: Palette.primaryColor,
              inactiveForegroundColor: Colors.grey,
            ),
          ),
        ];

    return PersistentTabView(
      tabs: navBarsItems(),
      navBarBuilder: (navBarConfig) => Style1BottomNavBar(
        navBarConfig: navBarConfig,
      ),
      handleAndroidBackButtonPress: false,
      onTabChanged: (value) async {},
    );
  }
}
