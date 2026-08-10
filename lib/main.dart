import 'package:chat_app/core/supabase_config.dart';
import 'package:chat_app/features/auth/presentation/screens/setup_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/provider/provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/navigation/presentation/nav_main_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    publishableKey: SUPABASE_KEY,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProviderApp(),
      child: Consumer<ProviderApp>(
        builder: (context, value, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: value.themeMode,
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(value.mainColor),
              brightness: Brightness.dark,
            ),
          ),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(value.mainColor),
              brightness: Brightness.light,
            ),
          ),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (FirebaseAuth.instance.currentUser!.displayName == '' ||
                    FirebaseAuth.instance.currentUser!.displayName == null) {
                  return const SetupProfileScreen();
                } else {
                  return const NavMainScreen();
                }
              } else {
                return const LoginScreen();
              }
            },
          ),
          //  const NavMainScreen(),
        ),
      ),
    );
  }
}
