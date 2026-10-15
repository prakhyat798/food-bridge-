import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasCeramic,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/onboarding');
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.donorPrimary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.heartHandshake, color: AppColors.donorPrimary, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'FoodBridge',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(LucideIcons.logIn, size: 16, color: AppColors.donorPrimary),
            label: Text(
              'Sign In',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.donorPrimary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dynamic Role Hub',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose your primary role on FoodBridge. You can always change this later.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _MaterialYouRoleCard(
                      title: 'Donor',
                      subtitle: 'I have surplus food from a kitchen, hotel, or household.',
                      icon: LucideIcons.soup,
                      backgroundColor: AppColors.donorContainer,
                      textColor: AppColors.donorOnContainer,
                      accentColor: AppColors.donorPrimary,
                      badgeText: 'Direct Rescue',
                      onTap: () async {
                        await saveRole('donor');
                        if (context.mounted) context.go('/donor/home');
                      },
                    ),
                    const SizedBox(height: 18),
                    _MaterialYouRoleCard(
                      title: 'NGO Shelter',
                      subtitle: 'I represent a verified community hunger relief center.',
                      icon: LucideIcons.building2,
                      backgroundColor: AppColors.ngoContainer,
                      textColor: AppColors.ngoOnContainer,
                      accentColor: AppColors.ngoPrimary,
                      badgeText: 'Shelter Hub',
                      onTap: () async {
                        await saveRole('ngo');
                        if (context.mounted) context.go('/ngo/home');
                      },
                    ),
                    const SizedBox(height: 18),
                    _MaterialYouRoleCard(
                      title: 'Volunteer Courier',
                      subtitle: 'I transport surplus meals from donors to shelters.',
                      icon: LucideIcons.bike,
                      backgroundColor: AppColors.riderContainer,
                      textColor: AppColors.riderOnContainer,
                      accentColor: AppColors.riderPrimary,
                      badgeText: 'Active Fleet',
                      onTap: () async {
                        await saveRole('rider');
                        if (context.mounted) context.go('/rider/home');
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialYouRoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;
  final String badgeText;
  final VoidCallback onTap;

  const _MaterialYouRoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          splashColor: Colors.white.withOpacity(0.35),
          highlightColor: Colors.white.withOpacity(0.18),
          child: Stack(
            children: [
              // Subtle background organic wave/circle motif
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.12,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icon, color: accentColor, size: 28),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  badgeText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: textColor.withOpacity(0.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: textColor.withOpacity(0.85),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

