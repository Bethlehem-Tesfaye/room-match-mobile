import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../models/property.dart';
import '../providers/property_provider.dart';
import '../widgets/favorite_icon_button.dart';
import '../widgets/property_network_image.dart';

const Color _kAccentColor = Color(0xFFD946A6);
const Color _kBackground = Color(0xFFF7F8FB);
const Color _kSurface = Colors.white;
const Color _kBodyText = Color(0xFF111827);
const Color _kCaption = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final PageController _pageController = PageController();
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadPropertyDetails(widget.propertyId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.selectedProperty == null) {
          return const Scaffold(
            backgroundColor: _kBackground,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.errorMessage != null && provider.selectedProperty == null) {
          return Scaffold(
            backgroundColor: _kBackground,
            appBar: AppBar(
              backgroundColor: _kBackground,
              elevation: 0,
              foregroundColor: _kBodyText,
            ),
            body: _buildError(provider.errorMessage!, provider),
          );
        }

        final property = provider.selectedProperty;
        if (property == null) {
          return Scaffold(
            backgroundColor: _kBackground,
            appBar: AppBar(backgroundColor: _kBackground, elevation: 0),
            body: _buildError('Property not found', provider),
          );
        }

        return _buildContent(property);
      },
    );
  }

  Widget _buildError(String message, PropertyProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: _kCaption),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kAccentColor),
              onPressed: () =>
                  provider.loadPropertyDetails(widget.propertyId),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Property property) {
    final owner = property.owner;
    final images = property.resolvedImages;
    final contactPhone = property.phone.isNotEmpty
        ? property.phone
        : owner?.phone ?? '';
    final contactEmail = property.email.isNotEmpty
        ? property.email
        : owner?.email ?? '';

    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 280,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (i) => setState(() => _imageIndex = i),
                            itemBuilder: (_, index) => PropertyNetworkImage(
                              url: images[index],
                              width: double.infinity,
                              height: 280,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _circleIconButton(
                            Icons.arrow_back,
                            () => Navigator.pop(context),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FavoriteIconButton(
                                propertyId: property.id,
                                property: property,
                                lightBackground: true,
                              ),
                              const SizedBox(width: 8),
                              _circleIconButton(
                                Icons.share_outlined,
                                () => _shareProperty(property),
                              ),
                            ],
                          ),
                        ),
                        if (images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                images.length,
                                (i) => Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i == _imageIndex
                                        ? _kAccentColor
                                        : Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: _kBodyText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            property.formattedPrice,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _kAccentColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _infoRow(Icons.home_work_outlined, property.propertyType),
                          _infoRow(Icons.bed_outlined, property.bedroomLabel),
                          _infoRow(Icons.location_on_outlined, property.address),
                          _infoRow(Icons.place_outlined, property.location),
                          const SizedBox(height: 20),
                          const Text(
                            'Amenities',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _kBodyText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (property.amenities.isEmpty)
                            const Text(
                              'No amenities listed',
                              style: TextStyle(color: _kCaption),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: property.amenities
                                  .map(
                                    (a) => Chip(
                                      label: Text(a),
                                      backgroundColor: const Color(0xFFEDE9FE),
                                      side: BorderSide.none,
                                    ),
                                  )
                                  .toList(),
                            ),
                          const SizedBox(height: 20),
                          _detailTile('Availability', property.availabilityDate),
                          _detailTile('Lease length', property.leaseLength),
                          const SizedBox(height: 24),
                          const Text(
                            'Owner contact',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _kBodyText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _contactCard(
                            name: owner?.fullName ?? 'Property owner',
                            phone: contactPhone,
                            email: contactEmail,
                            avatarUrl: owner?.avatarUrl,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: _kSurface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: contactPhone.isEmpty
                          ? null
                          : () => _callOwner(contactPhone),
                      icon: const Icon(Icons.phone),
                      label: const Text('Call Owner'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kAccentColor,
                        side: const BorderSide(color: _kAccentColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: contactEmail.isEmpty
                          ? null
                          : () => _contactOwner(contactEmail),
                      icon: const Icon(Icons.mail_outline),
                      label: const Text('Contact Owner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: _kBodyText),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _kCaption),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: _kBodyText)),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _kCaption)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, color: _kBodyText),
          ),
        ],
      ),
    );
  }

  Widget _contactCard({
    required String name,
    required String phone,
    required String email,
    String? avatarUrl,
  }) {
    final resolvedAvatar = avatarUrl != null && avatarUrl.isNotEmpty
        ? ApiConfig.resolveUrl(avatarUrl)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFEDE9FE),
            backgroundImage:
                resolvedAvatar != null ? NetworkImage(resolvedAvatar) : null,
            child: resolvedAvatar == null
                ? const Icon(Icons.person, color: _kAccentColor)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _kBodyText,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(phone, style: const TextStyle(color: _kCaption)),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(email, style: const TextStyle(color: _kCaption)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callOwner(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _contactOwner(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _shareProperty(Property property) async {
    final text =
        '${property.title}\n${property.formattedPrice}\n${property.address}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listing details copied to clipboard')),
    );
  }
}
