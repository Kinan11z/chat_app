import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/utils/validators.dart';
import 'package:chat_app/core/utils/widgets/app_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../auth/data/models/user_model.dart';
import '../manager/group/group_bloc.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  late TextEditingController groupNameController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<String> members = [];
  List<String> myContacts = [];
  @override
  void initState() {
    super.initState();
    groupNameController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              title: Text('Create group'),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  if (members.isNotEmpty) {
                    context.read<GroupBloc>().add(
                          CreateGroupEvent(
                            name: groupNameController.text,
                            members: members,
                          ),
                        );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please Enter Members'),
                      ),
                    );
                  }
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
                              child: Icon(Iconsax.user),
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
                    StreamBuilder(
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
                                    whereIn:
                                        myContacts.isEmpty ? [''] : myContacts)
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
                                    .toList()
                                  ..sort(
                                    (a, b) => a.name!.compareTo(b.name!),
                                  );
                                return Expanded(
                                  child: ListView.builder(
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
