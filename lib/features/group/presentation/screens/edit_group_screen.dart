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
import '../../domain/entities/chat_group_entity.dart';
import '../manager/group/group_bloc.dart';
import 'create_group_screen.dart' show MemberCheckboxTile;

class EditGroupScreen extends StatefulWidget {
  final ChatGroupEntity groupInfo;
  const EditGroupScreen({super.key, required this.groupInfo});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  late TextEditingController nameCon;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File? imageFile;
  Uint8List? imageBytes;
  String? imageExtension;
  final List<String> selectedMembers = [];
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    nameCon = TextEditingController(text: widget.groupInfo.name);
    selectedMembers.addAll(widget.groupInfo.members);
    final myId = getIt<SessionCubit>().state.user?.id ?? '';
    isAdmin = widget.groupInfo.admins.contains(myId);
  }

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
          final myId = context.read<SessionCubit>().state.user?.id ?? '';
          final isAdminNow = widget.groupInfo.admins.contains(myId);

          return Scaffold(
            appBar: AppBar(title: const Text('Edit Group')),
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
                                  : (widget.groupInfo.image!.isNotEmpty
                                      ? NetworkImage(widget.groupInfo.image!)
                                      : null),
                              backgroundColor:
                                  scheme.primary.withOpacity(0.10),
                              child: imageFile == null &&
                                      widget.groupInfo.image!.isEmpty
                                  ? Icon(Iconsax.camera,
                                      size: 28, color: scheme.primary)
                                  : null,
                            ),
                          ),
                          if (isAdminNow)
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
                          return Center(child: Text(contactsState.message));
                        }
                        if (contactsState is ContactsLoaded) {
                          final available = contactsState.contacts
                              .where((c) => c.id != myId)
                              .toList();

                          final currentMembers = available
                              .where((c) =>
                                  widget.groupInfo.members.contains(c.id))
                              .toList();
                          final others = available
                              .where((c) =>
                                  !widget.groupInfo.members.contains(c.id))
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (currentMembers.isNotEmpty) ...[
                                const _SectionLabel(title: 'CURRENT MEMBERS'),
                                ...currentMembers.map(
                                  (user) => MemberCheckboxTile(
                                    name: user.name,
                                    email: user.email,
                                    imageUrl: user.imageUrl,
                                    value: true,
                                    onChanged: isAdminNow
                                        ? (val) {
                                            if (val == false) {
                                              setState(() =>
                                                  selectedMembers
                                                      .remove(user.id));
                                            }
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                              if (others.isNotEmpty) ...[
                                const _SectionLabel(title: 'ADD MEMBERS'),
                                ...others.map(
                                  (user) => MemberCheckboxTile(
                                    name: user.name,
                                    email: user.email,
                                    imageUrl: user.imageUrl,
                                    value:
                                        selectedMembers.contains(user.id),
                                    onChanged: isAdminNow
                                        ? (val) {
                                            setState(() {
                                              if (val == true) {
                                                selectedMembers.add(user.id);
                                              } else {
                                                selectedMembers
                                                    .remove(user.id);
                                              }
                                            });
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 24),
                    if (isAdminNow)
                      AppButton(
                        isLoading: state is GroupLoadding,
                        onPressed: state is GroupLoadding
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  context.read<GroupBloc>().add(
                                        EditGroupEvent(
                                          groupId: widget.groupInfo.id,
                                          name: nameCon.text.trim(),
                                          members: selectedMembers,
                                          // imageFile: imageBytes,
                                          // fileExtension: imageExtension,
                                        ),
                                      );
                                }
                              },
                        icon: Iconsax.tick_circle,
                        text: 'Save Changes',
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
