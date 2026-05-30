import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/property.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../widgets/property_network_image.dart';
import 'add_property_screen.dart';
import 'property_details_screen.dart';

const Color _kAccentColor = Color(0xFFD946A6);
const Color _kBackground = Color(0xFFF7F8FB);
const Color _kSurface = Colors.white;
const Color _kBodyText = Color(0xFF111827);
const Color _kCaption = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key, this.onListingsChanged});

  final VoidCallback? onListingsChanged;

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final ownerId = context.read<AuthProvider>().user?.id;
    if (ownerId != null) {
      context.read<PropertyProvider>().loadMyProperties(ownerId);
    }
  }

  Future<void> _openAddProperty() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
    );
    if (!mounted) return;
    _load();
    widget.onListingsChanged?.call();
  }

  Future<void> _openEdit(Property property) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddPropertyScreen(propertyToEdit: property),
      ),
    );
    if (!mounted) return;
    _load();
    widget.onListingsChanged?.call();
  }

  Future<void> _confirmDelete(Property property) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text(
          'Remove "${property.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<PropertyProvider>();
    final ok = await provider.deleteProperty(property.id);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing deleted')),
      );
      widget.onListingsChanged?.call();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.errorMessage ?? 'Delete failed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PropertyProvider>();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Properties',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _kBodyText,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: _kAccentColor),
            onPressed: _openAddProperty,
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(PropertyProvider provider) {
    if (provider.isLoading && provider.myProperties.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.myProperties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(provider.errorMessage!, textAlign: TextAlign.center),
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

    if (provider.myProperties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.apartment_outlined, size: 64, color: _kAccentColor),
              const SizedBox(height: 20),
              const Text(
                'No listings yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _kBodyText,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Post your first property to start receiving inquiries.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _kCaption, height: 1.5),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccentColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _openAddProperty,
                child: const Text(
                  'Post Property',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        itemCount: provider.myProperties.length,
        itemBuilder: (context, index) {
          return _OwnerPropertyCard(
            property: provider.myProperties[index],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PropertyDetailsScreen(
                    propertyId: provider.myProperties[index].id,
                  ),
                ),
              );
            },
            onEdit: () => _openEdit(provider.myProperties[index]),
            onDelete: () => _confirmDelete(provider.myProperties[index]),
          );
        },
      ),
    );
  }
}

class _OwnerPropertyCard extends StatelessWidget {
  const _OwnerPropertyCard({
    required this.property,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Property property;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kBorder),
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
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: PropertyNetworkImage(
                url: property.displayImage,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _kBodyText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        property.formattedPrice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kAccentColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${property.propertyType} · ${property.bedroomLabel}',
                        style: const TextStyle(fontSize: 13, color: _kCaption),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: _kCaption,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _kCaption,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kAccentColor,
                          side: const BorderSide(color: _kAccentColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
