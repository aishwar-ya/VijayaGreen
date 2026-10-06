import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ============================================================
  // GOLDEN GREEN THEME
  // ============================================================

  static const Color deepForest = Color(0xFF123524);
  static const Color mainGreen = Color(0xFF24543A);
  static const Color gold = Color(0xFFD4A72C);
  static const Color olive = Color(0xFF7B8F3A);
  static const Color cream = Color(0xFFF7F3E7);
  static const Color softCream = Color(0xFFFCFAF3);
  static const Color mutedText = Color(0xFF687267);
  static const Color borderGreen = Color(0xFFD7E2D5);
  static const Color errorRed = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: deepForest),
        ),

        title: const Text(
          'Profile',
          style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
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
              constraints: const BoxConstraints(maxWidth: 390),
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
                      const Text(
                        'VijayaGreen',
                        style: TextStyle(
                          color: mutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Garden Accounts Made Simple',
                    style: TextStyle(color: mutedText, fontSize: 11),
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
          colors: [deepForest, mainGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold, width: 1),
        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.18),
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
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: gold.withValues(alpha: 0.7), width: 2),
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

          // ========================================================
          // GARDEN NAME
          // ========================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gold.withValues(alpha: 0.55)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_florist_outlined, color: gold, size: 16),
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
        border: Border.all(color: borderGreen),
        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.03),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Garden Information',
            style: TextStyle(
              color: deepForest,
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

          const Divider(height: 24, color: borderGreen),

          _buildInfoRow(
            icon: Icons.person_outline,
            title: 'Owner Name',
            value: 'ayshu',
          ),

          const Divider(height: 24, color: borderGreen),

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
            color: Color(0xFFE8F0E8),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: mainGreen, size: 21),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: mutedText, fontSize: 11),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  color: deepForest,
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
        border: Border.all(color: borderGreen),
        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.03),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: deepForest,
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

          const Divider(height: 1, color: borderGreen),

          _buildSettingTile(
            icon: Icons.backup_outlined,
            title: 'Backup Database',
            subtitle: 'Save a copy of your VijayaGreen data',
            onTap: () {
              _backupDatabase(context);
            },
          ),

          const Divider(height: 1, color: borderGreen),

          _buildSettingTile(
            icon: Icons.restore_outlined,
            title: 'Restore Database',
            subtitle: 'Restore data from a previous backup',
            onTap: () {
              _restoreDatabase(context);
            },
          ),

          const Divider(height: 1, color: borderGreen),

          const Divider(height: 1, color: borderGreen),

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
          color: Color(0xFFE8F0E8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: mainGreen, size: 21),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: deepForest,
        ),
      ),

      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: mutedText),
      ),

      trailing: const Icon(Icons.chevron_right, color: mutedText),

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

        icon: const Icon(Icons.logout, color: errorRed),

        label: const Text(
          'Logout',
          style: TextStyle(
            color: errorRed,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFAFA),
          side: const BorderSide(color: Color(0xFFE57373)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BACKUP DATABASE
  // ============================================================

  Future<void> _backupDatabase(BuildContext context) async {
    _showLoadingDialog(context, 'Creating backup...');

    final backupPath = await DatabaseHelper.instance.backupDatabase();

    if (context.mounted) {
      Navigator.pop(context);
    }

    if (!context.mounted) return;

    if (backupPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database backup saved successfully 🌿'),
          backgroundColor: deepForest,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // RESTORE DATABASE
  // ============================================================

  Future<void> _restoreDatabase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: softCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Restore Database',
            style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Restoring a backup will replace your current '
            'VijayaGreen data. Do you want to continue?',
            style: TextStyle(color: mutedText, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel', style: TextStyle(color: mutedText)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mainGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    _showLoadingDialog(context, 'Restoring database...');

    final restored = await DatabaseHelper.instance.restoreDatabase();

    if (context.mounted) {
      Navigator.pop(context);
    }

    if (!context.mounted) return;

    if (restored) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: softCream,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Restore Complete',
              style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Your VijayaGreen database has been restored successfully.',
              style: TextStyle(color: mutedText, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: mainGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database restore was cancelled or failed.'),
          backgroundColor: errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // LOADING DIALOG
  // ============================================================

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: softCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: mainGreen,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: deepForest,
                    fontWeight: FontWeight.w600,
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
  // COMING SOON
  // ============================================================

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be added later 🌿'),
        backgroundColor: deepForest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          backgroundColor: softCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),

          title: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0E8),
                  shape: BoxShape.circle,
                  border: Border.all(color: gold),
                ),
                child: Image.asset(
                  'assets/images/vijayagreen_icon.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'VijayaGreen',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: deepForest,
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
            style: TextStyle(color: mutedText, height: 1.5, fontSize: 13),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Close',
                style: TextStyle(color: mainGreen, fontWeight: FontWeight.w600),
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
          backgroundColor: softCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Logout',
            style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
          ),

          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: mutedText),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel', style: TextStyle(color: mutedText)),
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
                backgroundColor: errorRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
