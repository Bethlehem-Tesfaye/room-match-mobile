import 'package:flutter/material.dart';

import '../config/api_config.dart';

const Color _kAccentColor = Color(0xFFD946A6);

/// Profile image from API, or a default person icon when none is set.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.radius = 21,
    this.backgroundColor = const Color(0xFFEDE9FE),
  });

  final String? avatarUrl;
  final double radius;
  final Color backgroundColor;

  bool get _hasImage => avatarUrl != null && avatarUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage:
          _hasImage ? NetworkImage(ApiConfig.resolveUrl(avatarUrl!)) : null,
      child: _hasImage
          ? null
          : Icon(
              Icons.person,
              size: radius * 1.1,
              color: _kAccentColor,
            ),
    );
  }
}

/// Square avatar for the home app bar (rounded corners).
class UserAvatarTile extends StatelessWidget {
  const UserAvatarTile({
    super.key,
    this.avatarUrl,
    this.size = 42,
  });

  final String? avatarUrl;
  final double size;

  bool get _hasImage => avatarUrl != null && avatarUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFFEDE9FE),
        child: _hasImage
            ? Image.network(
                ApiConfig.resolveUrl(avatarUrl!),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(size),
              )
            : _placeholder(size),
      ),
    );
  }

  Widget _placeholder(double size) {
    return Center(
      child: Icon(
        Icons.person,
        size: size * 0.55,
        color: _kAccentColor,
      ),
    );
  }
}
