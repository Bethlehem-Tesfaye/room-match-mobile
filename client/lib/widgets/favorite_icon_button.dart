import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/property.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/property_provider.dart';

const Color _kAccentColor = Color(0xFFD946A6);

/// Heart toggle for tenants only. Updates UI immediately, then syncs with API.
class FavoriteIconButton extends StatelessWidget {
  const FavoriteIconButton({
    super.key,
    required this.propertyId,
    this.property,
    this.iconSize = 24,
    this.lightBackground = false,
  });

  final String propertyId;
  final Property? property;
  final double iconSize;
  final bool lightBackground;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null || user.isOwner) {
      return const SizedBox.shrink();
    }

    final favorites = context.watch<FavoriteProvider>();
    final isFav = favorites.isFavorite(propertyId);

    Widget icon = Icon(
      isFav ? Icons.favorite : Icons.favorite_border,
      color: _kAccentColor,
      size: iconSize,
    );

    if (lightBackground) {
      icon = Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.92),
          shape: BoxShape.circle,
        ),
        child: icon,
      );
    }

    return GestureDetector(
      onTap: () => _toggle(context),
      child: icon,
    );
  }

  void _toggle(BuildContext context) {
    Property? prop = property;
    if (prop == null) {
      final all = context.read<PropertyProvider>().allProperties;
      for (final p in all) {
        if (p.id == propertyId) {
          prop = p;
          break;
        }
      }
      prop ??= context.read<FavoriteProvider>().findPropertyInCache(propertyId);
    }

    context.read<FavoriteProvider>().toggleFavorite(propertyId, property: prop);
  }
}
