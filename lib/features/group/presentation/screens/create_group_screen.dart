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
import '../../../home/presentation/widgets/fallback_avatar.dart';
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
  bool membersError = false;

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
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withOpacity(0.55);

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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: scheme.primary.withOpacity(0.35),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 44,
                              backgroundImage: imageFile != null
                                  ? FileImage(imageFile!)
                                  : null,
                              backgroundColor:
                                  scheme.primary.withOpacity(0.10),
                              child: imageFile == null
                                  ? Icon(Iconsax.camera,
                                      size: 28, color: scheme.primary)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Material(
                              color: scheme.primary,
                              shape: const CircleBorder(),
                              elevation: 3,
                              shadowColor:
                                  scheme.primary.withOpacity(0.4),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _pickImage,
                                child: Padding(
                                  padding: const EdgeInsets.all(9),
                                  child: Icon(
                                    Iconsax.edit_2,
                                    size: 16,
                                    color: scheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    AppTextField(
                      controller: nameCon,
                      label: 'Group Name',
                      textInputAction: TextInputAction.done,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    const _SectionLabel(title: 'SELECT MEMBERS'),
                    if (membersError)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Text(
                          'Select at least one member',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.error,
                          ),
                        ),
                      ),
                    BlocBuilder<ContactsCubit, ContactsState>(
                      builder: (context, contactsState) {
                        if (contactsState is ContactsLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        if (contactsState is ContactsError) {
                          return Center(
                              child: Text(contactsState.message));
                        }
                        if (contactsState is ContactsLoaded) {
                          final myId =
                              context.read<SessionCubit>().state.user?.id ?? '';
                          final available = contactsState.contacts
                              .where((c) => c.id != myId)
                              .toList();

                          if (available.isEmpty) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No contacts found. Add contacts first.',
                                style:
                                    TextStyle(fontSize: 13, color: muted),
                              ),
                            );
                          }
                          return Column(
                            children: available.map((user) {
                              final isSelected =
                                  selectedMembers.contains(user.id);
                              return MemberCheckboxTile(
                                name: user.name,
                                email: user.email,
                                imageUrl: user.imageUrl,
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    membersError = false;
                                    if (val == true) {
                                      selectedMembers.add(user.id);
                                    } else {
                                      selectedMembers.remove(user.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      isLoading: state is GroupLoadding,
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
                              } else if (selectedMembers.isEmpty) {
                                setState(() => membersError = true);
                              }
                            },
                      icon: Iconsax.people,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }
}

class MemberCheckboxTile extends StatelessWidget {
  const MemberCheckboxTile({
    super.key,
    required this.name,
    required this.email,
    required this.value,
    this.imageUrl,
    this.onChanged,
  });

  final String name;
  final String email;
  final String? imageUrl;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.trailing,
        activeColor: scheme.primary,
        checkColor: scheme.onPrimary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: value
                ? scheme.primary.withOpacity(0.35)
                : scheme.onSurface.withOpacity(0.07),
          ),
        ),
        tileColor: value
            ? scheme.primary.withOpacity(0.05)
            : scheme.onSurface.withOpacity(0.02),
        secondary: FallbackAvatar(
          name: name,
          imageUrl: imageUrl,
          radius: 20,
        ),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
