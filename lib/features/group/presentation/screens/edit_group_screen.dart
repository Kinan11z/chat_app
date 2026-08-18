import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/utils/widgets/app_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/utils/validators.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/chat_group_entity.dart';
import '../manager/group/group_bloc.dart';
import 'group_member_screen.dart';

class EditGroupScreen extends StatefulWidget {
  const EditGroupScreen({super.key, required this.groupInfo});

  final ChatGroupEntity groupInfo;
  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  TextEditingController groupNameController =
      TextEditingController(text: 'group name');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<String> members = [];
  List myContacts = [];

  @override
  void initState() {
    super.initState();
    groupNameController.text = widget.groupInfo.name!;
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.groupInfo.admins!
        .contains(FirebaseAuth.instance.currentUser!.uid);
    return BlocProvider(
      create: (context) => getIt<GroupBloc>(),
      child: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupSuccess) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Edit group'),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GroupMemberScreen(groupInfo: widget.groupInfo),
                      ),
                    );
                  },
                  icon: Icon(Iconsax.user_edit),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  context.read<GroupBloc>().add(
                        EditGroupEvent(
                          groupId: widget.groupInfo.id!,
                          name: groupNameController.text,
                          members: members,
                        ),
                      );
                }
              },
              label: state is GroupLoadding
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Text('Done'),
              icon: state is GroupLoadding ? null : Icon(Iconsax.tick_circle),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 40,
                            ),
                            Positioned(
                              bottom: -10,
                              right: -10,
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.add_a_photo),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: AppTextField(
                            controller: groupNameController,
                            label: 'Group name',
                            prefixIcon: Icon(Iconsax.user_octagon),
                            validator: Validators.name,
                          ),
                        )
                      ],
                    ),
                    Divider(
                      height: 48,
                    ),
                    Row(
                      children: [
                        Text("Members"),
                        Spacer(),
                        Text(members.length.toString()),
                      ],
                    ),
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            myContacts = List<String>.from(
                                snapshot.data?.data()?['my_users'] ?? []);
                            return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .where('id',
                                      whereIn: myContacts.isEmpty
                                          ? ['']
                                          : myContacts)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List<UserModel> users = snapshot.data!.docs
                                      .map(
                                        (e) => UserModel.fromJson(e.data()),
                                      )
                                      .where(
                                        (element) =>
                                            element.id !=
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                      )
                                      .where(
                                        (element) => !widget.groupInfo.members!
                                            .contains(element.id),
                                      )
                                      .toList()
                                    ..sort(
                                      (a, b) => a.name!.compareTo(b.name!),
                                    );
                                  return ListView.builder(
                                    itemCount: users.length,
                                    itemBuilder: (context, index) =>
                                        CheckboxListTile(
                                      value: members.contains(users[index].id),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            members.add(users[index].id!);
                                          } else {
                                            members.remove(users[index].id!);
                                          }
                                        });
                                      },
                                      checkboxShape: CircleBorder(),
                                      title: Text(users[index].name!),
                                    ),
                                  );
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    )
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
