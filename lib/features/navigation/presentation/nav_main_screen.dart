import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/provider.dart';
import '../../auth/data/models/user_model.dart';
import '../../home/presentation/screens/chats_home_screen.dart';
import '../../home/presentation/screens/contact_home_screen.dart';
import '../../home/presentation/screens/groups_home_screen.dart';
import '../../home/presentation/screens/settings_home_screen.dart';

class NavMainScreen extends StatefulWidget {
  const NavMainScreen({super.key});

  @override
  State<NavMainScreen> createState() => _NavMainScreenState();
}

class _NavMainScreenState extends State<NavMainScreen> {
  PageController pageController = PageController();
  int currentIndex = 0;
  List<Widget> screens = const [
    ChatsHomeScreen(),
    GroupsHomeScreen(),
    ContactHomeScreen(),
    SettingsHomeScreen()
  ];
  @override
  void initState() {
    super.initState();
    Provider.of<ProviderApp>(context, listen: false).init();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user = Provider.of<ProviderApp>(context).user;
    return Scaffold(
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              children: screens,
            ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Iconsax.message), label: "Chat"),
          NavigationDestination(icon: Icon(Iconsax.messages), label: "Group"),
          NavigationDestination(icon: Icon(Iconsax.user), label: "Contacts"),
          NavigationDestination(icon: Icon(Iconsax.setting), label: "Setting"),
        ],
        onDestinationSelected: (index) => setState(() {
          currentIndex = index;
          pageController.jumpToPage(index);
        }),
      ),
    );
  }
}
