import 'package:flutter/material.dart';

import '../services/dummy_data_service.dart';
import 'add_property_screen.dart';
import 'profile_screen.dart';

const Color _kAccentColor = Color(0xFFD946A6);
const Color _kBackground = Color(0xFFF7F8FB);
const Color _kSurface = Colors.white;
const Color _kBodyText = Color(0xFF111827);
const Color _kCaption = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DummyHomeData? _homeData;
  final Set<String> _activeFilters = {};
  final TextEditingController _locationFilterController = TextEditingController();
  final TextEditingController _budgetFilterController = TextEditingController();
  String _roomTypeFilter = 'Apartment';

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  Future<void> _loadDummyData() async {
    final service = await DummyDataService.instance;
    if (!mounted) return;
    setState(() => _homeData = service.home);
  }

  @override
  void dispose() {
    _locationFilterController.dispose();
    _budgetFilterController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredListings(
    List<Map<String, dynamic>> items,
  ) {
    return items.where(_matchesFilters).toList();
  }

  bool _matchesFilters(Map<String, dynamic> item) {
    if (_activeFilters.contains('Location')) {
      final query = _locationFilterController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        final location = (item['location'] as String? ?? '').toLowerCase();
        final address = (item['address'] as String? ?? '').toLowerCase();
        if (!location.contains(query) && !address.contains(query)) {
          return false;
        }
      }
    }

    if (_activeFilters.contains('Budget')) {
      final budgetText = _budgetFilterController.text.trim();
      if (budgetText.isNotEmpty) {
        final maxBudget = double.tryParse(
          budgetText.replaceAll(RegExp(r'[^0-9.]'), ''),
        );
        final rent = (item['rentAmount'] as num?)?.toDouble() ??
            _parseRentFromPrice(item['price'] as String?);
        if (maxBudget != null && rent != null && rent > maxBudget) {
          return false;
        }
      }
    }

    if (_activeFilters.contains('Room type')) {
      final propertyType = item['propertyType'] as String? ?? '';
      if (propertyType.toLowerCase() != _roomTypeFilter.toLowerCase()) {
        return false;
      }
    }

    return true;
  }

  double? _parseRentFromPrice(String? price) {
    if (price == null) return null;
    final match = RegExp(r'[\d.]+').firstMatch(price);
    return match != null ? double.tryParse(match.group(0)!) : null;
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

    return 'Filtered by: ${parts.join(', ')}';
  }

  void _toggleFilter(String label) {
    setState(() {
      if (_activeFilters.contains(label)) {
        _activeFilters.remove(label);
        if (label == 'Location') _locationFilterController.clear();
        if (label == 'Budget') _budgetFilterController.clear();
      } else {
        _activeFilters.add(label);
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _activeFilters.clear();
      _locationFilterController.clear();
      _budgetFilterController.clear();
      _roomTypeFilter = 'Apartment';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_homeData == null) {
      return const Scaffold(
        backgroundColor: _kBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final homeData = _homeData!;
    final featuredListings = _filteredListings(homeData.featuredListings);
    final recentListings = _filteredListings(homeData.recentListings);

    return Scaffold(
      backgroundColor: _kBackground,
      extendBody: true,
      appBar: PreferredSize(
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
                    'RoomRental',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _kBodyText,
                    ),
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(homeData.headerAvatarUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Good morning, ${homeData.greetingName}',
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
                    '${recentListings.length} ${homeData.roomsNearText}',
                    style: const TextStyle(fontSize: 14, color: _kCaption),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _buildSearchBar(),
              const SizedBox(height: 18),
              _buildFilterChips(homeData),
              if (_activeFilters.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildActiveFilterInputs(homeData),
              ],
              const SizedBox(height: 24),
              _buildSectionHeader('Featured listings', 'See all'),
              const SizedBox(height: 18),
              _buildFeaturedList(featuredListings),
              const SizedBox(height: 26),
              _buildSectionHeader(
                'Recent listings',
                _filterSummary,
                showBadge: false,
              ),
              const SizedBox(height: 18),
              ...recentListings.map(_buildRecentCard),
              const SizedBox(height: 20),
              _buildNoMatchesCard(),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _kAccentColor,
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddPropertyScreen()));
        },
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
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
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search by location, uni, or keyword',
                hintStyle: TextStyle(color: _kCaption),
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _kAccentColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterInputs(DummyHomeData homeData) {
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
              onChanged: (_) => setState(() {}),
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
              onChanged: (_) => setState(() {}),
            ),
            if (_activeFilters.contains('Room type')) const SizedBox(height: 14),
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
                  items: homeData.roomTypeOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _roomTypeFilter = value);
                    }
                  },
                ),
              ),
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

  Widget _buildFilterChips(DummyHomeData homeData) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: homeData.filterChips.map((label) {
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

  Widget _buildFeaturedList(List<Map<String, dynamic>> listings) {
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

  Widget _buildFeaturedCard(Map<String, dynamic> item, double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          const BoxShadow(
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
                  child: Image.network(
                    item['image']!,
                    width: width,
                    height: width * 0.58,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
                  child: Row(
                    children: const [
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
                  item['price']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kAccentColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['title']!,
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
                        item['location']!,
                        style: const TextStyle(fontSize: 12, color: _kCaption),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['details']!,
                  style: const TextStyle(fontSize: 12, color: _kCaption),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          const BoxShadow(
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
            child: Image.network(
              item['image']!,
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
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _kBodyText,
                        ),
                      ),
                    ),
                    const Icon(Icons.favorite_border, color: _kAccentColor),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['price']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kAccentColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['snippet']!,
                  style: const TextStyle(fontSize: 14, color: _kCaption),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildTagRow(
                      icon: Icons.location_on_outlined,
                      text: item['location']!,
                    ),
                    _buildTagRow(
                      icon: Icons.circle,
                      text: item['distance']!,
                      iconSize: 8,
                    ),
                    _buildTagText(item['roommates']!),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item['address']!,
                  style: const TextStyle(fontSize: 12, color: _kCaption),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'AVAILABLE NOW',
                    style: TextStyle(
                      fontSize: 12,
                      color: _kAccentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagRow({
    required IconData icon,
    required String text,
    double iconSize = 14,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: _kCaption),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: _kCaption)),
      ],
    );
  }

  Widget _buildTagText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _kBorder),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: _kCaption)),
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

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: _kSurface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: _kAccentColor),
              onPressed: () {},
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.person_outline, color: _kCaption),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
