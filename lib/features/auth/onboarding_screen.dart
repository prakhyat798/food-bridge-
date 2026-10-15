import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasCeramic,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // ── Top Brand Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.donorContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.heartHandshake,
                          color: AppColors.donorPrimary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'FoodBridge',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.donorContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Material You',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.donorOnContainer,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // ── Hero Visual Graphics ──
              Center(
                child: SizedBox(
                  width: 320,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ambient pastel glowing backdrop rings
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.donorContainer.withOpacity(0.35),
                        ),
                      ),
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.donorContainer.withOpacity(0.5),
                        ),
                      ),

                      // Center Hero Squircle Icon
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1B4332), // Deep Forest Green
                              Color(0xFF2E6B4F), // Sage Primary
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B4332).withOpacity(0.28),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.soup,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),

                      // Floating Role Badge 1: Donors (Top Left)
                      Positioned(
                        top: 10,
                        left: 0,
                        child: _buildFloatingBadge(
                          icon: LucideIcons.leaf,
                          label: 'Surplus Food Rescued',
                          backgroundColor: const Color(0xFFE8F4EC),
                          iconColor: const Color(0xFF1B4332),
                          textColor: const Color(0xFF1B4332),
                        ),
                      ),

                      // Floating Role Badge 2: Shelters (Top Right)
                      Positioned(
                        top: 25,
                        right: 0,
                        child: _buildFloatingBadge(
                          icon: LucideIcons.building2,
                          label: 'NGO Shelters',
                          backgroundColor: const Color(0xFFFDF1E6),
                          iconColor: const Color(0xFFA04E28),
                          textColor: const Color(0xFFA04E28),
                        ),
                      ),

                      // Floating Role Badge 3: Volunteer Couriers (Bottom Center)
                      Positioned(
                        bottom: 8,
                        child: _buildFloatingBadge(
                          icon: LucideIcons.bike,
                          label: 'Rapid Courier Dispatch',
                          backgroundColor: const Color(0xFFD0E3EE),
                          iconColor: const Color(0xFF173752),
                          textColor: const Color(0xFF173752),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // ── Display Headline & Subtitle ──
              Text(
                'Rescue surplus.\nFeed the future.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.0,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Connecting commercial kitchens, hunger relief centers, and volunteer couriers in real-time.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 22),

              // ── Feature Highlights Row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeaturePill(LucideIcons.sparkles, 'AI Freshness'),
                  const SizedBox(width: 8),
                  _buildFeaturePill(LucideIcons.radar, 'Live Radar'),
                  const SizedBox(width: 8),
                  _buildFeaturePill(LucideIcons.shieldCheck, '2-Step OTP'),
                ],
              ),

              const Spacer(flex: 2),

              // ── Primary Action Pill (56dp height) ──
              GestureDetector(
                onTap: () => context.go('/role-selection'),
                child: Container(
                  height: 56,
                  width: double.infinity,
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
                        color: const Color(0xFF2E6B4F).withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.arrowRight, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Secondary Action (I already have an account) ──
              TextButton(
                onPressed: () => context.push('/login'),
                child: Text(
                  'I already have an account',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.donorPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBadge({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.donorPrimary),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
