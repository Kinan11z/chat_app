import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../contact/presentation/manager/contact/contact_bloc.dart';
import '../../../contact/presentation/manager/contacts/contacts_cubit.dart';
import '../../../contact/presentation/widgets/contact_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ContactsCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contacts'),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.add),
              onPressed: () => _showAddContactDialog(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchCon,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Iconsax.search_normal_1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: BlocBuilder<ContactsCubit, ContactsState>(
                builder: (context, state) {
                  if (state is ContactsLoading) {
                    return const Center(child: CircularProgressIndicator());
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
                      return const Center(child: Text('لا توجد جهات اتصال'));
                    }
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          ContactCard(user: filtered[index]),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
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
        child: AlertDialog(
          title: const Text('Add Contact'),
          content: TextField(
            controller: emailCon,
            decoration: const InputDecoration(hintText: 'Email'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
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
              builder: (context, state) => TextButton(
                onPressed: state is ContactLoadding
                    ? null
                    : () {
                        context.read<ContactBloc>().add(
                              AddContactEvent(email: emailCon.text.trim()),
                            );
                      },
                child: state is ContactLoadding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
