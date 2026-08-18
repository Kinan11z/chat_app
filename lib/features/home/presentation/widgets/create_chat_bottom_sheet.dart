import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/widgets/app_button.dart';
import '../../../../core/utils/widgets/app_text_field.dart';
import '../../../chat/presentation/manager/chat_room/chat_room_bloc.dart';

class CreateChatBottomSheet extends StatefulWidget {
  const CreateChatBottomSheet({
    super.key,
  });

  @override
  State<CreateChatBottomSheet> createState() => _CreateChatBottomSheetState();
}

class _CreateChatBottomSheetState extends State<CreateChatBottomSheet> {
  late TextEditingController emailController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatRoomBloc>(),
      child: BlocListener<ChatRoomBloc, ChatRoomState>(
        listener: (context, state) {
          if (state is ChatRoomSuccess) {
            // emailController.text = '';
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ChatRoomError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      "Enter Friend Email",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    IconButton.filled(
                      onPressed: () {},
                      icon: const Icon(Iconsax.scan_barcode),
                    )
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                AppTextField(
                  controller: emailController,
                  prefixIcon: const Icon(Iconsax.direct),
                  label: "Email",
                  validator: Validators.email,
                ),
                const SizedBox(
                  height: 16,
                ),
                BlocBuilder<ChatRoomBloc, ChatRoomState>(
                  builder: (context, state) {
                    if (state is ChatRoomLoadding) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return AppButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<ChatRoomBloc>().add(
                                CreateChatRoomEvent(
                                  email: emailController.text,
                                ),
                              );
                        }
                      },
                      text: 'Create Chat',
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
