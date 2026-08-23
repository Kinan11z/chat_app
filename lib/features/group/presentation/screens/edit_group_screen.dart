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
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: isAdminNow ? _pickImage : null,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: imageFile != null
                              ? FileImage(imageFile!)
                              : (widget.groupInfo.image!.isNotEmpty
                                  ? NetworkImage(widget.groupInfo.image!)
                                  : null),
                          child: imageFile == null &&
                                  widget.groupInfo.image!.isEmpty
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
                    const Text('Members',
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
                          final available = contactsState.contacts
                              .where((c) => c.id != myId)
                              .toList();

                          // الأعضاء الحاليين للمجموعة
                          final currentMembers = available
                              .where((c) =>
                                  widget.groupInfo.members.contains(c.id))
                              .toList();
                          // الباقون للإضافة
                          final others = available
                              .where((c) =>
                                  !widget.groupInfo.members.contains(c.id))
                              .toList();

                          return Column(
                            children: [
                              if (currentMembers.isNotEmpty) ...[
                                const Text('Current Members',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                ...currentMembers
                                    .map((user) => CheckboxListTile(
                                          title: Text(user.name),
                                          subtitle: Text(user.email),
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
                                        )),
                              ],
                              if (others.isNotEmpty) ...[
                                const Text('Add Members',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                ...others.map((user) => CheckboxListTile(
                                      title: Text(user.name),
                                      subtitle: Text(user.email),
                                      value: selectedMembers.contains(user.id),
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
                                    )),
                              ],
                            ],
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 24),
                    if (isAdminNow)
                      AppButton(
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
