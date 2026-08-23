import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../../core/utils/widgets/app_button.dart';
import '../../../../core/utils/widgets/app_text_field.dart';
import '../../../../core/utils/widgets/logo_app.dart';
import '../manager/auth/auth_bloc.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  late TextEditingController usernameController;
  GlobalKey formKey = GlobalKey<FormState>();

  @override
  void initState() {
    usernameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () => context.read<SessionCubit>().signOut(),
              icon: const Icon(Iconsax.logout_1),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LogoApp(),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    'New Chat App',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Please Enter Your Name",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: usernameController,
                    label: 'name',
                    prefixIcon: const Icon(Iconsax.user),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return AppButton(
                        onPressed: () => context.read<AuthBloc>().add(
                              CreateUserRequested(
                                name: usernameController.text.trim(),
                              ),
                            ),
                        text: 'Continue'.toUpperCase(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
