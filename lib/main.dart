import 'package:chat_app/core/presentation/session/session_state.dart';
import 'package:chat_app/core/supabase_config.dart';
import 'package:chat_app/features/auth/presentation/screens/setup_profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection.dart';
import 'core/presentation/session/session_cubit.dart';
import 'core/presentation/theme/theme_cubit.dart';
import 'core/presentation/theme/theme_state.dart';
import 'core/utils/services/notification_services.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/navigation/presentation/nav_main_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    publishableKey: SUPABASE_KEY,
  );
  FirebaseMessaging.onBackgroundMessage(messageBackHandler);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await init();
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  // String? token = await messaging.getToken();
  // print("FCM Registration Token: $token");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ThemeCubit>()),
        BlocProvider.value(value: getIt<SessionCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, theme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: theme.themeMode,
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(theme.mainColor),
                brightness: Brightness.dark,
              ),
            ),
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(theme.mainColor),
                brightness: Brightness.light,
              ),
            ),
            home: BlocBuilder<SessionCubit, SessionState>(
              builder: (context, session) {
                if (session.status == SessionStatus.authenticated) {
                  return const NavMainScreen();
                }
                if (session.status == SessionStatus.newUser) {
                  return const SetupProfileScreen();
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
