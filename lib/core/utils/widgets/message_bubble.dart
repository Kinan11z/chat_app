import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../helper_functions.dart';
import '../photo_view.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isMe,
    this.hasRead = true,
    this.senderName,
    this.isSelected = false,
  });

  final String message;
  final String type;
  final String createdAt;
  final bool isMe;
  final bool hasRead;
  final String? senderName;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withOpacity(0.55);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary.withOpacity(0.12) : null,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: EdgeInsets.fromLTRB(type == 'image' ? 6 : 14, 9,
              type == 'image' ? 6 : 14, 7),
          decoration: BoxDecoration(
            color: isMe ? scheme.primary : scheme.onSurface.withOpacity(0.06),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 5),
              bottomRight: Radius.circular(isMe ? 5 : 20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMe &&
                  senderName != null &&
                  senderName!.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    senderName!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
              ],
              if (type == 'image')
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoViewScreen(
                            imageProvider: NetworkImage(message),
                          ),
                        ),
                      ),
                      child: CachedNetworkImage(
                        height: 240,
                        width: MediaQuery.of(context).size.width * 0.58,
                        fit: BoxFit.cover,
                        imageUrl: message,
                        placeholder: (context, url) => Container(
                          color: scheme.onSurface.withOpacity(0.06),
                          child: const Center(
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.35,
                      color: isMe ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    HelperFunctions.localDateTime(createdAt),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isMe
                          ? scheme.onPrimary.withOpacity(0.75)
                          : muted,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Iconsax.tick_circle,
                      size: 15,
                      color: hasRead
                          ? scheme.onPrimary.withOpacity(0.95)
                          : scheme.onPrimary.withOpacity(0.45),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
