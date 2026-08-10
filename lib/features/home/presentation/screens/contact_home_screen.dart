import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/utils/widgets/app_button.dart';
import '../../../../core/utils/widgets/app_text_field.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../contact/presentation/manager/bloc/contact_bloc.dart';
import '../../../contact/presentation/widgets/contact_card.dart';

class ContactHomeScreen extends StatefulWidget {
  const ContactHomeScreen({super.key});

  @override
  State<ContactHomeScreen> createState() => _ContactHomeScreenState();
}

class _ContactHomeScreenState extends State<ContactHomeScreen> {
  bool isSearched = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController searchCon = TextEditingController();
  List<String> myContacts = [];

  @override
  void dispose() {
    emailController.dispose();
    searchCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearched
            ? TextField(
                controller: searchCon,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    isSearched = true;
                  });
                },
              )
            : const Text('Contact'),
        actions: [
          isSearched
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      isSearched = false;
                      searchCon.clear();
                    });
                  },
                  icon: Icon(Iconsax.close_square))
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isSearched = true;
                    });
                  },
                  icon: Icon(Iconsax.search_normal))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet(
            context: context,
            elevation: 10,
            builder: (context) {
              return BlocProvider(
                create: (context) => ContactBloc(),
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      BlocConsumer<ContactBloc, ContactState>(
                        listener: (context, state) {
                          if (state is ContactSuccess) {
                            Navigator.pop(context);
                            emailController.clear();
                          }
                        },
                        builder: (context, state) {
                          if (state is ContactLoadding) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return AppButton(
                            onPressed: () {
                              context.read<ContactBloc>().add(
                                    AddContactEvent(
                                      email: emailController.text,
                                    ),
                                  );
                            },
                            text: 'Add Contact',
                          );
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Iconsax.message_add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                            whereIn: myContacts.isEmpty ? [''] : myContacts)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<UserModel> users = snapshot.data!.docs
                            .map(
                              (e) => UserModel.fromJson(e.data()),
                            )
                            .where(
                              (element) => element.name!
                                  .toLowerCase()
                                  .startsWith(searchCon.text.toLowerCase()),
                            )
                            .toList()
                          ..sort(
                            (a, b) => a.name!.compareTo(b.name!),
                          );
                        return Expanded(
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) => ContactCard(
                              user: users[index],
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
    );
  }
}
