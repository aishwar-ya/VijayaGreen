import 'package:flutter/material.dart';

import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
        ),

        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  _buildProfileHeader(),

                  const SizedBox(height: 22),

                  _buildInformationCard(),

                  const SizedBox(height: 20),

                  _buildSettingsCard(context),

                  const SizedBox(height: 20),

                  _buildLogoutButton(context),

                  const SizedBox(height: 24),

                  // ==================================================
                  // BRANDING FOOTER
                  // ==================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/vijayagreen_icon.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'VijayaGreen',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Garden Accounts Made Simple',
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

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ========================================================
          // VIJAYAGREEN ICON
          // ========================================================

          Container(
            width: 86,
            height: 86,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/vijayagreen_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'ayshu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Owner',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 12),

          // Garden name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_florist_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'VIJAYA GARDEN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GARDEN INFORMATION
  // ============================================================

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Garden Information',
            style: TextStyle(
              color: Color(0xFF26332A),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.local_florist_outlined,
            title: 'Garden Name',
            value: 'VIJAYA GARDEN',
          ),

          const Divider(height: 24),

          _buildInfoRow(
            icon: Icons.person_outline,
            title: 'Owner Name',
            value: 'ayshu',
          ),

          const Divider(height: 24),

          _buildInfoRow(
            icon: Icons.business_outlined,
            title: 'Account Type',
            value: 'Owner Account',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 21),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF26332A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Color(0xFF26332A),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          _buildSettingTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () {
              _showComingSoon(context, 'Change Password');
            },
          ),

          const Divider(height: 1),

          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'About VijayaGreen',
            subtitle: 'Garden accounting application',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS TILE
  // ============================================================

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),

      leading: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFFE8F5E9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32), size: 21),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF26332A),
        ),
      ),

      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
      ),

      trailing: const Icon(Icons.chevron_right, color: Colors.grey),

      onTap: onTap,
    );
  }

  // ============================================================
  // LOGOUT BUTTON
  // ============================================================

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {
          _showLogoutDialog(context);
        },

        icon: const Icon(Icons.logout, color: Color(0xFFC62828)),

        label: const Text(
          'Logout',
          style: TextStyle(
            color: Color(0xFFC62828),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE57373)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be added later 🌿'),
        backgroundColor: const Color(0xFF26332A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // ABOUT DIALOG
  // ============================================================

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),

          title: Column(
            children: [
              Image.asset(
                'assets/images/vijayagreen_icon.png',
                width: 58,
                height: 58,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 12),

              const Text(
                'VijayaGreen',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          content: const Text(
            'VijayaGreen is a simple garden accounting '
            'application created for Vijaya Garden to '
            'manage income, expenses, customers, suppliers '
            'and financial reports.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF2E7D32)),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          content: const Text('Are you sure you want to logout?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
                elevation: 0,
              ),

              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
