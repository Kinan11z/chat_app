import 'package:flutter/material.dart';
import '../../../../core/utils/date_format.dart';
import '../../../group/domain/entities/chat_group_entity.dart';
import '../../../group/presentation/screens/group_screen.dart';
import 'fallback_avatar.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.groupInfo,
  });
  final ChatGroupEntity groupInfo;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withOpacity(0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              children: [
                FallbackAvatar(
                  name: groupInfo.name,
                  imageUrl: groupInfo.image,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupInfo.name.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        groupInfo.lastMessage == ''
                            ? 'No messages yet'
                            : groupInfo.lastMessage.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (groupInfo.lastMessageTime.isNotEmpty)
                  Text(
                    AppDateTimeFormatter.dateAndTime(
                      groupInfo.lastMessageTime,
                    ),
                    style: TextStyle(fontSize: 11.5, color: muted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
