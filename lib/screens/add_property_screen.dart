import 'package:flutter/material.dart';

const Color _kAccentColor = Color(0xFFD946A6);
const Color _kBackground = Color(0xFFF7F8FB);
const Color _kSurface = Colors.white;
const Color _kBodyText = Color(0xFF111827);
const Color _kCaption = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  String _propertyType = 'Apartment';
  int _bedrooms = 1;
  final Set<String> _selectedAmenities = {};
  DateTime _availableDate = DateTime.now();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        foregroundColor: _kBodyText,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post Property',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Post',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Property Photos'),
                  const SizedBox(height: 12),
                  _buildPhotoUploadCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Property Title'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _titleController,
                    hint: 'Enter title…',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _rentController,
                    label: 'Monthly Rent',
                    hint: r'ETB 0.00',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Location / Address',
                    hint: '4 Killo, Addis Ababa',
                    suffix: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: const Color(0xFFF5F2FF),
                      ),
                      icon: const Icon(
                        Icons.location_pin,
                        size: 18,
                        color: _kAccentColor,
                      ),
                      label: const Text(
                        'Use Current Location',
                        style: TextStyle(color: _kAccentColor, fontSize: 12),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Unit Details'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Property Type',
                          value: _propertyType,
                          options: const ['Apartment', 'House', 'Studio'],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _propertyType = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Number of Bedrooms',
                    style: TextStyle(
                      color: _kCaption,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(4, (index) {
                      final label = index < 3 ? '${index + 1}' : '3+';
                      final selected =
                          _bedrooms == index + 1 ||
                          (index == 3 && _bedrooms >= 4);
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 3 ? 10 : 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selected
                                  ? _kAccentColor
                                  : _kSurface,
                              foregroundColor: selected
                                  ? Colors.white
                                  : _kBodyText,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: selected ? _kAccentColor : _kBorder,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => setState(() {
                              _bedrooms = index == 3 ? 4 : index + 1;
                            }),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Amenities',
                    style: TextStyle(
                      color: _kCaption,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: [
                      'High-speed WiFi',
                      'Air Conditioning',
                      'Gym Access',
                      'Swimming Pool',
                      'No Smoking',
                      'Pet Friendly',
                      '24/7 Security',
                    ].map(_buildAmenityChip).toList(),
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Leasing & Terms'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Availability Date',
                          date: _availableDate,
                          onTap: () => _selectDate(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Lease Length',
                          value: '12 Months',
                          options: const ['6 Months', '12 Months', '24 Months'],
                          onChanged: (_) {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Contact Information'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: '+251 (9) 123-4567',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'owner@roommatch.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Publish Listing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      'By publishing, you agree to Room Match Terms & Service',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _kBodyText,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: _kBodyText,
      ),
    );
  }

  Widget _buildPhotoUploadCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _kBorder, style: BorderStyle.solid),
              color: const Color(0xFFF8F5FF),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 28,
                    color: _kAccentColor,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Tap to upload photos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _kBodyText,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Supports JPG, PNG Max 5MB',
                    style: TextStyle(fontSize: 12, color: _kCaption),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildThumbnailPlaceholder(),
                const SizedBox(width: 10),
                _buildThumbnailImage(
                  'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=200&q=80',
                ),
                const SizedBox(width: 10),
                _buildThumbnailImage(
                  'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=200&q=80',
                ),
                const SizedBox(width: 10),
                _buildThumbnailImage(
                  'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=200&q=80',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
        color: const Color(0xFFF8F5FF),
      ),
      child: const Center(child: Icon(Icons.add, color: _kAccentColor)),
    );
  }

  Widget _buildThumbnailImage(String imageUrl) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: TextStyle(
              color: _kCaption,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kBorder),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffix == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: suffix,
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: _kCaption, fontSize: 13, letterSpacing: 0.2),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: options.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _kCaption,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _kBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${date.month}/${date.day}/${date.year}',
                    style: const TextStyle(fontSize: 14, color: _kBodyText),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: _kCaption,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String label) {
    final selected = _selectedAmenities.contains(label);
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: _kAccentColor,
      backgroundColor: _kSurface,
      showCheckmark: false,
      onSelected: (_) => setState(() {
        if (selected) {
          _selectedAmenities.remove(label);
        } else {
          _selectedAmenities.add(label);
        }
      }),
      labelStyle: TextStyle(color: selected ? Colors.white : _kBodyText),
      side: BorderSide(color: selected ? _kAccentColor : _kBorder),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _availableDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _availableDate = picked;
      });
    }
  }
}
