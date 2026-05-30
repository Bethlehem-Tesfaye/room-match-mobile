import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/property_listing_card.dart';
import 'property_details_screen.dart';

const Color _kAccentColor = Color(0xFFD946A6);
const Color _kBackground = Color(0xFFF7F8FB);
const Color _kBodyText = Color(0xFF111827);
const Color _kCaption = Color(0xFF6B7280);

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, this.onBrowseProperties});

  /// Called when user taps "Browse Properties" (switch to Home tab).
  final VoidCallback? onBrowseProperties;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId != null) {
      context.read<FavoriteProvider>().loadFavorites(userId);
    }
  }

  void _openDetails(String propertyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailsScreen(propertyId: propertyId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoriteProvider>();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _kBodyText,
          ),
        ),
      ),
      body: _buildBody(favorites),
    );
  }

  Widget _buildBody(FavoriteProvider favorites) {
    if (favorites.isLoading && favorites.favoriteProperties.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favorites.errorMessage != null && favorites.favoriteProperties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(favorites.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _kAccentColor),
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (favorites.favoriteProperties.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        itemCount: favorites.favoriteProperties.length,
        itemBuilder: (context, index) {
          final property = favorites.favoriteProperties[index];
          return PropertyListingCard(
            property: property,
            onTap: () => _openDetails(property.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: _kAccentColor),
            const SizedBox(height: 20),
            const Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _kBodyText,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Save listings you like and they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _kCaption, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccentColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: widget.onBrowseProperties,
                child: const Text(
                  'Browse Properties',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
