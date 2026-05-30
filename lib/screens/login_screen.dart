import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

const Color _kAccentColor = Color(0xFFD946A6);
const Color _kBackground = Color(0xFFF7F8FB);
const Color _kSurface = Colors.white;
const Color _kBodyText = Color(0xFF111827);
const Color _kCaption = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _remember = false;
  bool _showPassword = false;

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  _buildRoomRentalLogo(),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _kBodyText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue ',
                    style: TextStyle(
                      fontSize: 14,
                      color: _kCaption,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  _buildInputField(
                    label: 'Email Address',
                    hint: 'hello@gmail.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          _remember = !_remember;
                        }),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _remember ? _kAccentColor : _kSurface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _kBorder),
                              ),
                              child: _remember
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Remember',
                              style: TextStyle(fontSize: 14, color: _kBodyText),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: _kAccentColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAccentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: const Text(
                        'Sign In',
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
                      borderRadius: BorderRadius.circular(18),
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
                  const SizedBox(height: 24),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(color: _kCaption, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: const TextStyle(
                              color: _kAccentColor,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
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
            borderRadius: BorderRadius.circular(18),
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
            borderRadius: BorderRadius.circular(18),
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

  Widget _buildRoomRentalLogo() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(217, 70, 166, 0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.home, size: 80, color: _kAccentColor),
              Positioned(
                bottom: 12,
                right: 12,
                child: Icon(Icons.bed, size: 32, color: _kAccentColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'RoomRental',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _kBodyText,
          ),
        ),
      ],
    );
  }
}
