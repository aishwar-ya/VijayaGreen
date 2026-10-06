import 'package:flutter/material.dart';

import 'login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController gardenNameController = TextEditingController(
    text: 'VIJAYA GARDEN',
  );

  final TextEditingController ownerNameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    gardenNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // VALIDATE AND CREATE ACCOUNT
  // ============================================================

  void createAccount() {
    final gardenName = gardenNameController.text.trim();
    final ownerName = ownerNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Empty field validation
    if (gardenName.isEmpty ||
        ownerName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    // Email validation
    if (!email.contains('@') || !email.contains('.')) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    // Phone validation
    if (phone.length < 10) {
      _showMessage('Please enter a valid phone number.');
      return;
    }

    // Password validation
    if (password.length < 6) {
      _showMessage('Password must contain at least 6 characters.');
      return;
    }

    // Password confirmation
    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    // Everything is valid
    _showAccountCreatedDialog(email);
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  void _showAccountCreatedDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 46,
                  color: Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Account Created!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your VijayaGreen owner account has been '
                'created successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B756B),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(initialEmail: email),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    'Continue to Login',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF26332A),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF7A847A), fontSize: 15),
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8E6D8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8E6D8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
    );
  }

  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374137),
      ),
    );
  }

  // ============================================================
  // BUILD SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FAF6),
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
        ),

        title: const Text(
          'Create Owner Account',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        centerTitle: true,
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            child: ConstrainedBox(
              // SAME MOBILE WIDTH AS LOGIN SCREEN
              constraints: const BoxConstraints(maxWidth: 390),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // VIJAYAGREEN LOGO
                  // ==================================================

                  Center(
                    child: SizedBox(
                      width: 250,
                      height: 185,
                      child: Image.asset(
                        'assets/images/vijayagreen_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // ==================================================
                  // TAGLINE
                  // ==================================================
                  const Center(
                    child: Text(
                      'Simple. Smart. Green.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF687368),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // WELCOME MESSAGE
                  // ==================================================
                  const Center(
                    child: Text(
                      'Create your owner account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Center(
                    child: Text(
                      'Set up your garden details to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // GARDEN NAME
                  // ==================================================
                  _buildLabel('Garden / Nursery Name'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: gardenNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      hint: 'Vijaya Garden',
                      icon: Icons.local_florist_outlined,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // OWNER NAME
                  // ==================================================
                  _buildLabel('Owner Name'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: ownerNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      hint: 'Enter owner name',
                      icon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // PHONE NUMBER
                  // ==================================================
                  _buildLabel('Phone Number'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      hint: 'Enter phone number',
                      icon: Icons.phone_outlined,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // EMAIL
                  // ==================================================
                  _buildLabel('Email Address'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      hint: 'Enter email address',
                      icon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // PASSWORD
                  // ==================================================
                  _buildLabel('Password'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: _inputDecoration(
                      hint: 'Create a password',
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // CONFIRM PASSWORD
                  // ==================================================
                  _buildLabel('Confirm Password'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    decoration: _inputDecoration(
                      hint: 'Re-enter your password',
                      icon: Icons.lock_reset_outlined,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // CREATE ACCOUNT BUTTON
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: createAccount,
                      icon: const Icon(Icons.person_add_alt_1, size: 21),
                      label: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // LOGIN LINK
                  // ==================================================
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                      ),
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // FOOTER
                  // ==================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        size: 17,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Vijaya Garden',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Owner Management System',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
