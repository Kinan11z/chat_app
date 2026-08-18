import 'package:chat_app/core/utils/validators.dart';
import 'package:chat_app/features/auth/presentation/manager/auth/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/widgets/app_button.dart';
import '../../../../core/utils/widgets/app_outline_button.dart';
import '../../../../core/utils/widgets/app_text_field.dart';
import '../../../../core/utils/widgets/logo_app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigator.pushAndRemoveUntil(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const SetupProfileScreen(),
            //   ),
            //   (route) => false,
            // );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(),
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
                      'Welcome Back!',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      'New Chat App',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: emailController,
                      label: 'Email',
                      prefixIcon: const Icon(Icons.mail_outline_outlined),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: passwordController,
                      label: 'Password',
                      prefixIcon: const Icon(Iconsax.check),
                      isPassword: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgetPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text('Forget Password?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AppButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    context.read<AuthBloc>().add(
                                          SignInRequested(
                                            email: emailController.text,
                                            password: passwordController.text,
                                          ),
                                        );
                                  }
                                },
                          text: 'Login'.toUpperCase(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return AppOutlineButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    context.read<AuthBloc>().add(
                                          SignUpRequested(
                                            email: emailController.text,
                                            password: passwordController.text,
                                          ),
                                        );
                                  }
                                },
                          text: 'Create Account'.toUpperCase(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
