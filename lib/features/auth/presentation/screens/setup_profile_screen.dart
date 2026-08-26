import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/widgets/app_button.dart';
import '../../../../core/utils/widgets/app_text_field.dart';
import '../manager/auth/auth_bloc.dart';
import '../widgets/auth_background.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  late TextEditingController usernameController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withOpacity(0.6);

    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: AuthBackground(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          Material(
                            color: scheme.onSurface.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () =>
                                  context.read<SessionCubit>().signOut(),
                              child: Padding(
                                padding: const EdgeInsets.all(11),
                                child: Icon(
                                  Iconsax.logout_1,
                                  size: 22,
                                  color: scheme.onSurface.withOpacity(0.75),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                scheme.primary,
                                Color.lerp(
                                    scheme.primary, scheme.secondary, 0.35)!,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withOpacity(0.35),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child:
                              const Icon(Iconsax.user, color: Colors.white, size: 44),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Set Up Your Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose the name people will see when you chat with them',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: muted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      AppTextField(
                        controller: usernameController,
                        label: 'Display Name',
                        prefixIcon:
                            Icon(Iconsax.user, size: 20, color: muted),
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.name],
                        validator: Validators.name,
                      ),
                      const SizedBox(height: 28),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final loading = state is AuthLoading;
                          return AppButton(
                            onPressed: loading
                                ? null
                                : () {
                                    if (formKey.currentState?.validate() ??
                                        false) {
                                      context.read<AuthBloc>().add(
                                            CreateUserRequested(
                                              name:
                                                  usernameController.text.trim(),
                                            ),
                                          );
                                    }
                                  },
                            isLoading: loading,
                            icon: Iconsax.arrow_right_3,
                            text: 'Continue',
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
      ),
    );
  }
}
