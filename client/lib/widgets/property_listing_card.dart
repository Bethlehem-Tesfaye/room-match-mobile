import 'package:flutter/material.dart';

import '../models/property.dart';
import 'favorite_icon_button.dart';
import 'property_network_image.dart';

const Color _kAccentColor = Color(0xFFD946A6);
const Color _kSurface = Colors.white;
const Color _kBodyText = Color(0xFF111827);
const Color _kCaption = Color(0xFF6B7280);

/// Recent-listing style card used on Home and Favorites.
class PropertyListingCard extends StatelessWidget {
  const PropertyListingCard({
    super.key,
    required this.property,
    required this.onTap,
    this.showFavorite = true,
  });

  final Property property;
  final VoidCallback onTap;
  final bool showFavorite;

  @override
  Widget build(BuildContext context) {
    final map = property.toRecentMap();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: PropertyNetworkImage(
                url: map['image'] as String,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          map['title'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _kBodyText,
                          ),
                        ),
                      ),
                      if (showFavorite)
                        FavoriteIconButton(
                          propertyId: property.id,
                          property: property,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    map['price'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kAccentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${property.propertyType} · ${property.bedroomLabel}',
                    style: const TextStyle(fontSize: 14, color: _kCaption),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: _kCaption,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          property.location,
                          style: const TextStyle(fontSize: 12, color: _kCaption),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.address,
                    style: const TextStyle(fontSize: 12, color: _kCaption),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
