import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const Color _kAccentColor = Color.fromARGB(255, 87, 3, 58);
const Color _kBackground = Color(0xFFF7F8FB);
const Color _kSurface = Colors.white;
const Color _kBodyText = Color(0xFF111827);
const Color _kCaption = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String _selectedGender = 'Female';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: _kBodyText),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [_buildRoomRentalLogoSmall()],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(217, 70, 166, 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Join the Community',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _kAccentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: _kBodyText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find your perfect living space and compatible roommates today.',
                    style: TextStyle(
                      fontSize: 14,
                      color: _kCaption,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80',
                      width: double.infinity,
                      height: 170,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _buildInputField(
                    label: 'Full Name',
                    hint: 'Abebe Kebede',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Email Address',
                    hint: 'abebe.kebede@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Phone Number',
                    hint: '+251 (9) 123-4567',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    label: 'Password',
                    hint: '******',
                    visible: _showPassword,
                    onToggle: () => setState(() {
                      _showPassword = !_showPassword;
                    }),
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    label: 'Confirm Password',
                    hint: '******',
                    visible: _showConfirmPassword,
                    onToggle: () => setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    }),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 14,
                      color: _kCaption,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildGenderChip('Male'),
                      const SizedBox(width: 10),
                      _buildGenderChip('Female'),
                      const SizedBox(width: 10),
                    ],
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
                      onPressed: () {},
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _kBorder),
                    ),
                    child: TextButton.icon(
                      icon: const Icon(Icons.login, color: _kBodyText),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(color: _kBodyText),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: const TextStyle(color: _kCaption, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Log in',
                            style: const TextStyle(
                              color: _kAccentColor,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pop(context);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChip(String label) {
    final bool selected = _selectedGender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedGender = label;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _kAccentColor : _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? _kAccentColor : _kBorder),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _kBodyText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            color: _kCaption,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder),
          ),
          child: TextField(
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon, color: _kCaption),
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            color: _kCaption,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder),
          ),
          child: TextField(
            obscureText: !visible,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: _kCaption),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  visible ? Icons.visibility : Icons.visibility_off,
                  color: _kCaption,
                ),
              ),
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomRentalLogoSmall() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(217, 70, 166, 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.home, size: 32, color: _kAccentColor),
              Positioned(
                bottom: 4,
                right: 4,
                child: Icon(Icons.bed, size: 14, color: _kAccentColor),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'RoomRental',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _kBodyText,
          ),
        ),
      ],
    );
  }
}
