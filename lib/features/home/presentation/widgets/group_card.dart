import 'package:chat_app/features/group/data/models/chat_group_model.dart';
import 'package:flutter/material.dart';
import '../../../group/presentation/screens/group_screen.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.groupInfo,
  });
  final ChatGroupModel groupInfo;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupScreen(
              groupInfo: groupInfo,
            ),
          ),
        );
      },
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            child: Text(groupInfo.name!.characters.first),
          ),
          title: Text(groupInfo.name.toString()),
          subtitle: Text(
            groupInfo.lastMessage == ''
                ? 'send first message'
                : groupInfo.lastMessage.toString(),
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 1,
          ),
          trailing: Badge(
            label: Text('2'),
          ),
        ),
      ),
    );
  }
}
