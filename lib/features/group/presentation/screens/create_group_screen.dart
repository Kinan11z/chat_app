import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../core/utils/widgets/app_button.dart';
import '../../../../core/utils/widgets/app_text_field.dart';
import '../../../contact/presentation/manager/contacts/contacts_cubit.dart';
import '../manager/group/group_bloc.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController nameCon = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File? imageFile;
  Uint8List? imageBytes;
  String? imageExtension;
  final List<String> selectedMembers = [];

  @override
  void dispose() {
    nameCon.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await HelperFunctions.pickImage();
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        imageFile = picked;
        imageBytes = bytes;
        imageExtension = picked.path.split('.').last;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<GroupBloc>()),
        BlocProvider(create: (_) => getIt<ContactsCubit>()),
      ],
      child: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is GroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Create Group')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              imageFile != null ? FileImage(imageFile!) : null,
                          child: imageFile == null
                              ? const Icon(Iconsax.camera, size: 30)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: nameCon,
                      label: 'Group Name',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Members',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    BlocBuilder<ContactsCubit, ContactsState>(
                      builder: (context, contactsState) {
                        if (contactsState is ContactsLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (contactsState is ContactsError) {
                          return Center(child: Text(contactsState.message));
                        }
                        if (contactsState is ContactsLoaded) {
                          final myId =
                              context.read<SessionCubit>().state.user?.id ?? '';
                          final available = contactsState.contacts
                              .where((c) => c.id != myId)
                              .toList();

                          if (available.isEmpty) {
                            return const Center(
                                child: Text('لا توجد جهات اتصال'));
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: available.length,
                            itemBuilder: (context, index) {
                              final user = available[index];
                              final isSelected =
                                  selectedMembers.contains(user.id);
                              return CheckboxListTile(
                                title: Text(user.name),
                                subtitle: Text(user.email),
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      selectedMembers.add(user.id);
                                    } else {
                                      selectedMembers.remove(user.id);
                                    }
                                  });
                                },
                              );
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      onPressed: state is GroupLoadding
                          ? null
                          : () {
                              if (formKey.currentState!.validate() &&
                                  selectedMembers.isNotEmpty) {
                                context.read<GroupBloc>().add(
                                      CreateGroupEvent(
                                        name: nameCon.text.trim(),
                                        members: selectedMembers,
                                        // imageFile: imageBytes,
                                        // fileExtension: imageExtension,
                                      ),
                                    );
                              }
                            },
                      text: 'Create Group',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
