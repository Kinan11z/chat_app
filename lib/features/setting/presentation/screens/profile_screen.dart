import 'dart:io';
import 'dart:typed_data';

import 'package:chat_app/core/utils/widgets/app_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
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
    final scheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) => getIt<ProfileBloc>(),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
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
                            radius: 58,
                            backgroundImage: imageUrl == ''
                                ? (user?.imageUrl != null &&
                                        user!.imageUrl!.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        user!.imageUrl!)
                                    : null)
                                : FileImage(File(imageUrl)),
                            child: imageUrl == '' &&
                                    (user?.imageUrl == null ||
                                        user!.imageUrl!.isEmpty)
                                ? Icon(Iconsax.user,
                                    size: 44, color: scheme.primary)
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
                              onTap: () {
                                HelperFunctions.pickImage().then(
                                  (file) async {
                                    if (file != null) {
                                      final pickedBytes =
                                          await file.readAsBytes();
                                      setState(() {
                                        imageUrl = file.path;
                                        bytes = pickedBytes;
                                      });
                                    }
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  Iconsax.edit_2,
                                  size: 18,
                                  color: scheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _ProfileEditField(
                    icon: Iconsax.user_octagon,
                    label: 'Name',
                    controller: nameCon,
                    enabled: nameEdit,
                    onToggle: () => setState(() => nameEdit = !nameEdit),
                  ),
                  const SizedBox(height: 12),
                  _ProfileEditField(
                    icon: Iconsax.information,
                    label: 'About',
                    controller: aboutCon,
                    enabled: aboutEdit,
                    onToggle: () => setState(() => aboutEdit = !aboutEdit),
                  ),
                  const SizedBox(height: 12),
                  _ProfileInfoRow(
                    icon: Iconsax.direct,
                    title: 'Email',
                    value: user!.email,
                  ),
                  const SizedBox(height: 12),
                  _ProfileInfoRow(
                    icon: Iconsax.timer_1,
                    title: 'Joined On',
                    value: user!.createdAt ?? '',
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      return AppButton(
                        isLoading: state is ProfileLoadding,
                        onPressed: state is ProfileLoadding
                            ? null
                            : () {
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
                                          fileExtension:
                                              imageUrl.split('.').last,
                                        ),
                                      );
                                }
                              },
                        text: 'Save Changes',
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileEditField extends StatelessWidget {
  const _ProfileEditField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.enabled,
    required this.onToggle,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withOpacity(0.55);

    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? scheme.primary.withOpacity(0.05)
            : scheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: enabled
              ? scheme.primary.withOpacity(0.35)
              : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 21, color: enabled ? scheme.primary : muted),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              cursorColor: scheme.primary,
              style: TextStyle(fontSize: 15, color: scheme.onSurface),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(fontSize: 13.5, color: muted),
                floatingLabelStyle:
                    TextStyle(fontSize: 12, color: scheme.primary),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: onToggle,
            splashRadius: 22,
            icon: Icon(
              Iconsax.edit_2,
              size: 18,
              color: enabled ? scheme.primary : muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withOpacity(0.55);

    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: scheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 21, color: muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: muted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
