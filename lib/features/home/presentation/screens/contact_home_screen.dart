import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../contact/presentation/manager/contact/contact_bloc.dart';
import '../../../contact/presentation/manager/contacts/contacts_cubit.dart';
import '../../../contact/presentation/widgets/contact_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_action_button.dart';
import '../widgets/home_header.dart';
import '../widgets/list_skeleton.dart';

class ContactHomeScreen extends StatefulWidget {
  const ContactHomeScreen({super.key});

  @override
  State<ContactHomeScreen> createState() => _ContactHomeScreenState();
}

class _ContactHomeScreenState extends State<ContactHomeScreen> {
  final TextEditingController searchCon = TextEditingController();

  @override
  void dispose() {
    searchCon.dispose();
    super.dispose();
  }

  InputDecoration get _searchDecoration {
    final scheme = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
      filled: true,
      fillColor: scheme.brightness == Brightness.dark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.035),
      hintText: 'Search contacts',
      hintStyle:
          TextStyle(fontSize: 14, color: scheme.onSurface.withOpacity(0.45)),
      prefixIcon:
          Icon(Iconsax.search_normal_1, size: 20, color: mutedIconColor),
      prefixIconColor: mutedIconColor,
      border: border(Colors.transparent, 1),
      enabledBorder: border(scheme.onSurface.withOpacity(0.08), 1),
      focusedBorder: border(scheme.primary, 1.5),
    );
  }

  Color get mutedIconColor =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.45);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ContactsCubit>(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                title: 'Contacts',
                actions: [
                  HomeActionButton(
                    icon: Iconsax.add,
                    onTap: () => _showAddContactDialog(context),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: TextField(
                  controller: searchCon,
                  decoration: _searchDecoration,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: BlocBuilder<ContactsCubit, ContactsState>(
                  builder: (context, state) {
                    if (state is ContactsLoading) {
                      return const ListSkeleton();
                    }
                    if (state is ContactsError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is ContactsLoaded) {
                      final contacts = state.contacts;
                      final filtered = searchCon.text.isEmpty
                          ? contacts
                          : contacts
                              .where((c) => c.name
                                  .toLowerCase()
                                  .contains(searchCon.text.toLowerCase()))
                              .toList();

                      if (filtered.isEmpty) {
                        if (searchCon.text.isNotEmpty) {
                          return const EmptyState(
                            icon: Iconsax.search_status,
                            title: 'No results',
                            subtitle: 'Try searching with a different name',
                          );
                        }
                        return const EmptyState(
                          icon: Iconsax.profile_2user,
                          title: 'No contacts yet',
                          subtitle:
                              "Tap the + button to add your friends by email",
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 110),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            ContactCard(user: filtered[index]),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final emailCon = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (_) => getIt<ContactBloc>(),
        child: Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color:
                          Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    ),
                    child: Icon(
                      Iconsax.profile_add,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Add Contact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Enter your friend's email address",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: emailCon,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(context, emailCon),
                  cursorColor: Theme.of(context).colorScheme.primary,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 18),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                    hintText: 'Email address',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.45),
                    ),
                    prefixIcon: const Icon(Iconsax.sms, size: 20),
                    prefixIconColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                BlocConsumer<ContactBloc, ContactState>(
                  listener: (context, state) {
                    if (state is ContactSuccess) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    } else if (state is ContactError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    final loading = state is ContactLoadding;
                    return SizedBox(
                      width: double.maxFinite,
                      child: FilledButton(
                        onPressed:
                            loading ? null : () => _submit(context, emailCon),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          disabledBackgroundColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.10),
                          disabledForegroundColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.38),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: loading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  strokeCap: StrokeCap.round,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                            : const Text(
                                'Add Contact',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context, TextEditingController emailCon) {
    context.read<ContactBloc>().add(
          AddContactEvent(email: emailCon.text.trim()),
        );
  }
}
