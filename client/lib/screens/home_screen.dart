import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/property.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/property_provider.dart';
import '../widgets/favorite_icon_button.dart';
import '../widgets/property_listing_card.dart';
import '../widgets/property_network_image.dart';
import '../widgets/user_avatar.dart';
import 'add_property_screen.dart';
import 'favorites_screen.dart';
import 'my_properties_screen.dart';
import 'profile_screen.dart';
import 'property_details_screen.dart';

const Color _kAccentColor = Color(0xFFD946A6);
const Color _kBackground = Color(0xFFF7F8FB);
const Color _kSurface = Colors.white;
const Color _kBodyText = Color(0xFF111827);
const Color _kCaption = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

const List<String> _filterChips = [
  'Location',
  'Budget',
  'Room type',
  'Bedrooms',
];

const List<String> _roomTypeOptions = ['Apartment', 'House', 'Studio'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> _activeFilters = {};
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationFilterController = TextEditingController();
  final TextEditingController _budgetFilterController = TextEditingController();
  String _roomTypeFilter = 'Apartment';
  int? _bedroomsFilter;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchListings();
      _loadFavorites();
      _loadMyPropertiesIfOwner();
    });
  }

  void _loadFavorites() {
    final user = context.read<AuthProvider>().user;
    if (user != null && !user.isOwner) {
      context.read<FavoriteProvider>().loadFavorites(user.id);
    }
  }

  void _loadMyPropertiesIfOwner() {
    final user = context.read<AuthProvider>().user;
    if (user != null && user.isOwner) {
      context.read<PropertyProvider>().loadMyProperties(user.id);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationFilterController.dispose();
    _budgetFilterController.dispose();
    super.dispose();
  }

  Future<void> _fetchListings() async {
    final searchParts = <String>[];
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) searchParts.add(searchText);
    if (_activeFilters.contains('Location')) {
      final loc = _locationFilterController.text.trim();
      if (loc.isNotEmpty) searchParts.add(loc);
    }

    double? maxBudget;
    if (_activeFilters.contains('Budget')) {
      final budgetText = _budgetFilterController.text.trim();
      if (budgetText.isNotEmpty) {
        maxBudget = double.tryParse(
          budgetText.replaceAll(RegExp(r'[^0-9.]'), ''),
        );
      }
    }

    String? propertyType;
    if (_activeFilters.contains('Room type')) {
      propertyType = _roomTypeFilter;
    }

    int? bedrooms;
    if (_activeFilters.contains('Bedrooms') && _bedroomsFilter != null) {
      bedrooms = _bedroomsFilter;
    }

    await context.read<PropertyProvider>().loadProperties(
      search: searchParts.isEmpty ? null : searchParts.join(' '),
      maxBudget: maxBudget,
      propertyType: propertyType,
      bedrooms: bedrooms,
    );
  }

  String get _filterSummary {
    if (_activeFilters.isEmpty) return 'Filtered by: all';

    final parts = <String>[];
    if (_activeFilters.contains('Location') &&
        _locationFilterController.text.trim().isNotEmpty) {
      parts.add('Location: ${_locationFilterController.text.trim()}');
    } else if (_activeFilters.contains('Location')) {
      parts.add('Location');
    }
    if (_activeFilters.contains('Budget') &&
        _budgetFilterController.text.trim().isNotEmpty) {
      parts.add('Budget: ${_budgetFilterController.text.trim()}');
    } else if (_activeFilters.contains('Budget')) {
      parts.add('Budget');
    }
    if (_activeFilters.contains('Room type')) {
      parts.add('Room type: $_roomTypeFilter');
    }
    if (_activeFilters.contains('Bedrooms') && _bedroomsFilter != null) {
      parts.add('Bedrooms: $_bedroomsFilter');
    }

    return 'Filtered by: ${parts.join(', ')}';
  }

  void _toggleFilter(String label) {
    setState(() {
      if (_activeFilters.contains(label)) {
        _activeFilters.remove(label);
        if (label == 'Location') _locationFilterController.clear();
        if (label == 'Budget') _budgetFilterController.clear();
        if (label == 'Bedrooms') _bedroomsFilter = null;
      } else {
        _activeFilters.add(label);
      }
    });
    _fetchListings();
  }

  void _resetFilters() {
    setState(() {
      _activeFilters.clear();
      _locationFilterController.clear();
      _budgetFilterController.clear();
      _roomTypeFilter = 'Apartment';
      _bedroomsFilter = null;
      _searchController.clear();
    });
    _fetchListings();
  }

  void _openPropertyDetails(String propertyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailsScreen(propertyId: propertyId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final propertyProvider = context.watch<PropertyProvider>();
    final user = auth.user;

    final isOwner = user?.isOwner == true;

    if (_tabIndex == 0 &&
        propertyProvider.isLoading &&
        propertyProvider.allProperties.isEmpty) {
      return const Scaffold(
        backgroundColor: _kBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _kBackground,
      extendBody: false,
      appBar: _tabIndex == 0 ? _buildHomeAppBar(user, isOwner) : null,
      body: _buildTabBody(isOwner, propertyProvider, user),
      floatingActionButton: isOwner && _tabIndex == 0
          ? FloatingActionButton(
              backgroundColor: _kAccentColor,
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
                );
                if (mounted) {
                  _fetchListings();
                  _loadMyPropertiesIfOwner();
                }
              },
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(isOwner),
    );
  }

  PreferredSizeWidget _buildHomeAppBar(AppUser? user, bool isOwner) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(90),
      child: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _kAccentColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.home, color: Colors.white, size: 22),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Icon(Icons.bed, color: Colors.white, size: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'RoomMatch',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _kBodyText,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _tabIndex = 2),
                child: UserAvatarTile(avatarUrl: user?.avatarUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBody(
    bool isOwner,
    PropertyProvider propertyProvider,
    AppUser? user,
  ) {
    if (isOwner) {
      return IndexedStack(
        index: _tabIndex,
        children: [
          _buildHomeListings(propertyProvider, user),
          MyPropertiesScreen(onListingsChanged: _fetchListings),
          const ProfileScreen(isTab: true),
        ],
      );
    }

    return IndexedStack(
      index: _tabIndex,
      children: [
        _buildHomeListings(propertyProvider, user),
        FavoritesScreen(
          onBrowseProperties: () => setState(() => _tabIndex = 0),
        ),
        const ProfileScreen(isTab: true),
      ],
    );
  }

  Widget _buildHomeListings(PropertyProvider propertyProvider, AppUser? user) {
    final featuredListings = propertyProvider.featuredListings;
    final recentListings = propertyProvider.recentListings;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchListings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Good morning, ${user?.firstName ?? 'there'}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _kBodyText,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: _kCaption,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${recentListings.length} rooms near you',
                    style: const TextStyle(fontSize: 14, color: _kCaption),
                  ),
                ],
              ),
              if (propertyProvider.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: _kAccentColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          propertyProvider.errorMessage!,
                          style: const TextStyle(color: _kBodyText),
                        ),
                      ),
                      TextButton(
                        onPressed: _fetchListings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              _buildSearchBar(),
              const SizedBox(height: 18),
              _buildFilterChips(),
              if (_activeFilters.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildActiveFilterInputs(),
              ],
              const SizedBox(height: 24),
              _buildSectionHeader('Featured listings', 'See all'),
              const SizedBox(height: 18),
              if (featuredListings.isEmpty)
                _buildEmptyListings('No featured listings yet')
              else
                _buildFeaturedList(featuredListings),
              const SizedBox(height: 26),
              _buildSectionHeader(
                'Recent listings',
                _filterSummary,
                showBadge: false,
              ),
              const SizedBox(height: 18),
              if (recentListings.isEmpty)
                _buildEmptyListings('No listings match your search')
              else
                ...recentListings.map(
                  (property) => PropertyListingCard(
                    property: property,
                    onTap: () => _openPropertyDetails(property.id),
                  ),
                ),
              const SizedBox(height: 20),
              if (recentListings.isEmpty) _buildNoMatchesCard(),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyListings(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.home_work_outlined, size: 40, color: _kCaption),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: _kCaption)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.search, color: _kCaption),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _fetchListings(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search by location, uni, or keyword',
                hintStyle: TextStyle(color: _kCaption),
              ),
            ),
          ),
          GestureDetector(
            onTap: _fetchListings,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _kAccentColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.tune, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterInputs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_activeFilters.contains('Location')) ...[
            _buildFilterFieldLabel('Location'),
            const SizedBox(height: 8),
            _buildFilterTextField(
              controller: _locationFilterController,
              hint: 'e.g. Camden Town, Addis Ababa',
              icon: Icons.location_on_outlined,
              onChanged: (_) => _fetchListings(),
            ),
            if (_activeFilters.length > 1) const SizedBox(height: 14),
          ],
          if (_activeFilters.contains('Budget')) ...[
            _buildFilterFieldLabel('Max Budget'),
            const SizedBox(height: 8),
            _buildFilterTextField(
              controller: _budgetFilterController,
              hint: r'ETB 5000',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
              onChanged: (_) => _fetchListings(),
            ),
            if (_activeFilters.contains('Room type') ||
                _activeFilters.contains('Bedrooms'))
              const SizedBox(height: 14),
          ],
          if (_activeFilters.contains('Room type')) ...[
            _buildFilterFieldLabel('Room Type'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: _kBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _roomTypeFilter,
                  isExpanded: true,
                  items: _roomTypeOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _roomTypeFilter = value);
                      _fetchListings();
                    }
                  },
                ),
              ),
            ),
            if (_activeFilters.contains('Bedrooms')) const SizedBox(height: 14),
          ],
          if (_activeFilters.contains('Bedrooms')) ...[
            _buildFilterFieldLabel('Bedrooms'),
            const SizedBox(height: 8),
            Row(
              children: [1, 2, 3, 4].map((n) {
                final selected = _bedroomsFilter == n;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: n < 4 ? 8 : 0),
                    child: ChoiceChip(
                      label: Text(n == 4 ? '3+' : '$n'),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _bedroomsFilter = n);
                        _fetchListings();
                      },
                      selectedColor: _kAccentColor,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : _kBodyText,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _kBodyText,
      ),
    );
  }

  Widget _buildFilterTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _kBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _kCaption),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: _kCaption, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filterChips.map((label) {
          final bool selected = _activeFilters.contains(label);
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => _toggleFilter(label),
              selectedColor: _kAccentColor,
              backgroundColor: _kSurface,
              labelStyle: TextStyle(
                color: selected ? Colors.white : _kBodyText,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String action, {
    bool showBadge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _kBodyText,
          ),
        ),
        Row(
          children: [
            if (showBadge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                ),
                child: const Text(
                  'University',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kAccentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (showBadge) const SizedBox(width: 10),
            Text(
              action,
              style: const TextStyle(
                fontSize: 14,
                color: _kAccentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedList(List<Property> listings) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        double cardWidth = screenWidth * 0.78;
        if (cardWidth < 280) cardWidth = 280;
        if (cardWidth > 340) cardWidth = 340;

        return SizedBox(
          height: cardWidth * 1.05,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: listings.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return SizedBox(
                width: cardWidth,
                child: _buildFeaturedCard(listings[index], cardWidth),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCard(Property property, double width) {
    final item = property.toFeaturedMap();
    final verified = property.verified;

    return GestureDetector(
      onTap: () => _openPropertyDetails(property.id),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  child: SizedBox(
                    width: width,
                    height: width * 0.58,
                    child: PropertyNetworkImage(
                      url: item['image'] as String,
                      width: width,
                      height: width * 0.58,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: FavoriteIconButton(
                    propertyId: property.id,
                    property: property,
                    lightBackground: true,
                  ),
                ),
                if (verified)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: _kAccentColor, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'VERIFIED',
                            style: TextStyle(
                              fontSize: 10,
                              color: _kBodyText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['price'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kAccentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kBodyText,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                          item['location'] as String,
                          style: const TextStyle(fontSize: 12, color: _kCaption),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['details'] as String,
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

  Widget _buildNoMatchesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No matches found?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kBodyText,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Try widening your search area or adjusting your budget filters to see more listings.',
            style: TextStyle(fontSize: 14, color: _kCaption, height: 1.5),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _resetFilters,
              child: const Text(
                'Reset filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isOwner) {
    if (!isOwner) {
      return BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (index) => setState(() => _tabIndex = index),
        selectedItemColor: _kAccentColor,
        unselectedItemColor: _kCaption,
        backgroundColor: _kSurface,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      );
    }

    return BottomNavigationBar(
      currentIndex: _tabIndex,
      onTap: (index) {
        setState(() => _tabIndex = index);
        if (index == 1) _loadMyPropertiesIfOwner();
      },
      selectedItemColor: _kAccentColor,
      unselectedItemColor: _kCaption,
      backgroundColor: _kSurface,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apartment_outlined),
          activeIcon: Icon(Icons.apartment),
          label: 'My Properties',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
