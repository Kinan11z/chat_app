import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FallbackAvatar extends StatelessWidget {
  const FallbackAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 26,
  });

  final String? imageUrl;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primary.withOpacity(0.14),
      backgroundImage:
          hasImage ? CachedNetworkImageProvider(imageUrl!) : null,
      child: hasImage
          ? null
          : Text(
              name.isNotEmpty ? name.characters.first.toUpperCase() : '?',
              style: TextStyle(
                fontSize: radius * 0.75,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
    );
  }
}
