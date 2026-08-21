import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/utils/widgets/app_button.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/presentation/session/session_cubit.dart';
import '../../../../core/utils/helper_functions.dart';
import '../manager/profile/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameCon = TextEditingController();
  TextEditingController aboutCon = TextEditingController();
  UserEntity? user;
  String imageUrl = '';
  Uint8List? bytes;
  bool nameEdit = false;
  bool aboutEdit = false;

  @override
  void initState() {
    user = context.read<SessionCubit>().state.user;
    super.initState();
    nameCon.text = user?.name ?? '';
    aboutCon.text = user?.about ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileBloc>(),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundImage: imageUrl == ''
                                ? (user?.imageUrl != null &&
                                        user!.imageUrl!.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        user!.imageUrl!)
                                    : null)
                                : FileImage(File(imageUrl)),
                          ),
                          Positioned(
                            bottom: -5,
                            right: -5,
                            child: IconButton.filled(
                              onPressed: () {
                                HelperFunctions.pickImage().then(
                                  (file) {
                                    if (file != null) {
                                      setState(() async {
                                        imageUrl = file.path;
                                        bytes = await file.readAsBytes();
                                      });
                                    }
                                  },
                                );
                              },
                              icon: Icon(
                                Iconsax.edit,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Iconsax.user_octagon,
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            setState(() {
                              nameEdit = !nameEdit;
                            });
                          },
                          child: Icon(Iconsax.edit),
                        ),
                        title: TextField(
                          controller: nameCon,
                          decoration: InputDecoration(
                            enabled: nameEdit,
                            border: InputBorder.none,
                            labelText: "Name",
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Iconsax.information),
                        trailing: GestureDetector(
                          onTap: () {
                            setState(() {
                              aboutEdit = !aboutEdit;
                            });
                          },
                          child: Icon(Iconsax.edit),
                        ),
                        title: TextField(
                          controller: aboutCon,
                          enabled: aboutEdit,
                          decoration: InputDecoration(
                            labelText: "About",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                          leading: Icon(Iconsax.direct),
                          title: Text("Email"),
                          subtitle: Text(user!.email)),
                    ),
                    Card(
                      child: ListTile(
                          leading: Icon(Iconsax.timer_1),
                          title: Text("Joined On"),
                          subtitle: Text(user!.createdAt ?? '')),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        if (state is ProfileLoadding) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return AppButton(
                          onPressed: () {
                            if (nameCon.text.isNotEmpty ||
                                aboutCon.text.isNotEmpty ||
                                imageUrl.isNotEmpty) {
                              context.read<ProfileBloc>().add(
                                    UpdateProfileDetails(
                                      name: nameCon.text.isNotEmpty
                                          ? nameCon.text
                                          : null,
                                      about: aboutCon.text.isNotEmpty
                                          ? aboutCon.text
                                          : null,
                                      imageFile: bytes,
                                      fileExtension: imageUrl.split('.').last,
                                    ),
                                  );
                            }
                          },
                          text: 'Save',
                        );
                      },
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
