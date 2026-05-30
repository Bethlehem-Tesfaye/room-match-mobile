import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../navigation/app_navigator.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/user_avatar.dart';

const Color _kAccentColor = Color(0xFFD946A6);
const Color _kBackground = Color(0xFFF7F8FB);
const Color _kSurface = Colors.white;
const Color _kBodyText = Color(0xFF111827);
const Color _kCaption = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.isTab = false});

  /// When true, shown as a bottom-nav tab (no close button).
  final bool isTab;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  XFile? _pickedAvatar;
  Uint8List? _avatarBytes;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _loadFromAuth();
  }

  void _loadFromAuth() {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    _nameController.text = user.fullName;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _bioController.text = user.bio;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedAvatar = image;
        _avatarBytes = bytes;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_bioController.text.length > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bio must be 150 characters or less')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
      avatar: _pickedAvatar,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.errorMessage ?? 'Update failed')),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    context.read<FavoriteProvider>().clear();
    if (!mounted) return;
    navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: _kBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            if (!widget.isTab)
              IconButton(
                icon: const Icon(Icons.close, color: _kBodyText),
                onPressed: () => Navigator.of(context).pop(),
              ),
            Expanded(
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _kBodyText,
                ),
              ),
            ),
            if (!widget.isTab)
              TextButton(
              onPressed: auth.isSubmitting ? null : _saveProfile,
              child: auth.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kAccentColor,
                      ),
                    ),
              ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(32),
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Update your personal information and preferences.',
                style: TextStyle(fontSize: 14, color: _kCaption),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _avatarBytes != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: MemoryImage(_avatarBytes!),
                          )
                        : UserAvatar(
                            avatarUrl: user.avatarUrl,
                            radius: 60,
                          ),
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _kAccentColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: _kSurface, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _pickAvatar,
                child: const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _kAccentColor,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              _buildTextField(
                controller: _nameController,
                label: 'Full name',
                hintText: 'Your full name',
                icon: Icons.person,
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _emailController,
                label: 'Email address',
                hintText: 'your@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone number',
                hintText: '+251...',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _bioController,
                label: 'Bio / Status',
                hintText: 'Tell others about yourself',
                icon: Icons.notes_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Maximum 150 characters',
                  style: TextStyle(fontSize: 12, color: _kCaption),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: auth.isSubmitting ? null : _saveProfile,
                  child: const Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _logout,
                child: const Text(
                  'Log out',
                  style: TextStyle(color: _kCaption),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _kCaption),
        hintText: hintText,
        hintStyle: const TextStyle(color: _kCaption),
        prefixIcon: Icon(icon, color: _kCaption),
        filled: true,
        fillColor: _kSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kAccentColor),
        ),
      ),
    );
  }
}
