import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class DonorProfileTab extends ConsumerWidget {
  const DonorProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Profile Card (28dp Squircle) ──
          Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1B4332), // Deep Forest Green
                  Color(0xFF2E6B4F), // Sage Primary
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4332).withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Ambient botanical decorative circles
                Positioned(
                  right: -25,
                  top: -25,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),
                Positioned(
                  left: -15,
                  bottom: -35,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD2E7D6).withOpacity(0.08),
                    ),
                  ),
                ),
                Column(
                  children: [
                    // Avatar with glowing frosted border
                    Center(
                      child: Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(LucideIcons.user, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ref.watch(userSessionProvider).name.isNotEmpty
                          ? ref.watch(userSessionProvider).name
                          : 'Food Donor',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ref.watch(userSessionProvider).phone.isNotEmpty
                          ? '+91 ${ref.watch(userSessionProvider).phone} · Mumbai, India'
                          : 'Donor Partner · Mumbai, India',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFD2E7D6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌱', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Text(
                            'Verified Impact Donor',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Stats Row (3 Tonal Squircles) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                _buildStatCard(
                  value: '1,284',
                  label: 'Meals Rescued',
                  icon: LucideIcons.utensils,
                  containerColor: const Color(0xFFE8F4EC),
                  accentColor: AppColors.donorPrimary,
                  textColor: const Color(0xFF1B4332),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  value: '87',
                  label: 'Donations',
                  icon: LucideIcons.packageCheck,
                  containerColor: const Color(0xFFDDF0E4),
                  accentColor: const Color(0xFF0D652D),
                  textColor: const Color(0xFF0D652D),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  value: '4.9 ⭐',
                  label: 'Donor Rating',
                  icon: LucideIcons.star,
                  containerColor: const Color(0xFFFDF1E6),
                  accentColor: const Color(0xFFA04E28),
                  textColor: const Color(0xFFA04E28),
                ),
              ],
            ),
          ),

          // ── Group 1: Account Preferences ──
          _buildSectionHeader('Account & Preferences'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withOpacity(0.04), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.025),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  icon: LucideIcons.user,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal details',
                  bubbleColor: const Color(0xFFE8F4EC),
                  iconColor: AppColors.donorPrimary,
                  onTap: () {},
                ),
                _buildInnerDivider(),
                _buildSettingTile(
                  icon: LucideIcons.mapPin,
                  title: 'Saved Addresses',
                  subtitle: 'Manage surplus pickup locations',
                  bubbleColor: const Color(0xFFE8F4EC),
                  iconColor: AppColors.donorPrimary,
                  onTap: () {},
                ),
                _buildInnerDivider(),
                _buildSettingTile(
                  icon: LucideIcons.bell,
                  title: 'Notifications',
                  subtitle: 'Manage pickup and delivery alerts',
                  bubbleColor: const Color(0xFFE8F4EC),
                  iconColor: AppColors.donorPrimary,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Group 2: System & Session ──
          _buildSectionHeader('System & Security'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withOpacity(0.04), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.025),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  icon: LucideIcons.arrowLeftRight,
                  title: 'Switch Role Hub',
                  subtitle: 'Change active mode to NGO or Courier',
                  bubbleColor: const Color(0xFFD0E3EE),
                  iconColor: const Color(0xFF173752),
                  onTap: () => context.go('/role-selection'),
                ),
                _buildInnerDivider(),
                _buildSettingTile(
                  icon: LucideIcons.shieldCheck,
                  title: 'Privacy & Safety',
                  subtitle: 'Data protection and food safety guidelines',
                  bubbleColor: const Color(0xFFE8F4EC),
                  iconColor: AppColors.donorPrimary,
                  onTap: () {},
                ),
                _buildInnerDivider(),
                _buildSettingTile(
                  icon: LucideIcons.helpCircle,
                  title: 'Help & Support',
                  subtitle: 'FAQs and hunger relief community support',
                  bubbleColor: const Color(0xFFE8F4EC),
                  iconColor: AppColors.donorPrimary,
                  onTap: () {},
                ),
                _buildInnerDivider(),
                _buildSettingTile(
                  icon: LucideIcons.logOut,
                  title: 'Sign Out',
                  subtitle: 'Log out of FoodBridge',
                  bubbleColor: const Color(0xFFFDE8E8),
                  iconColor: const Color(0xFFC53030),
                  titleColor: const Color(0xFFC53030),
                  onTap: () async {
                    await ref.read(userSessionProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),

          // Clearance padding for floating dock
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 6),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color containerColor,
    required Color accentColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 16),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bubbleColor,
    required Color iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: Colors.black.withOpacity(0.2),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInnerDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 62,
      endIndent: 18,
      color: Colors.black.withOpacity(0.04),
    );
  }
}
