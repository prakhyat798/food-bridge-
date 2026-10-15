import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class DonorDashboardTab extends ConsumerWidget {
  const DonorDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donations = ref.watch(donationsProvider);
    final activeDonationList = donations.where((d) => d.status == DonationStatus.inTransit).toList();
    final activeDonation = activeDonationList.isNotEmpty ? activeDonationList.first : null;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildGreetingCard(context, donations),
        ),
        if (activeDonation != null)
          SliverToBoxAdapter(
            child: _buildActiveDonationBanner(context, activeDonation),
          ),
        SliverToBoxAdapter(
          child: _buildStatsRow(context, donations),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Text(
                  'Recent Donations',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.donorContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.donorPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Live Activity',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.donorOnContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        donations.isEmpty
            ? const SliverToBoxAdapter(child: _EmptyDonationsState())
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _DonationTile(donation: donations[index]),
                  childCount: donations.length,
                ),
              ),
        // Extra bottom padding to ensure floating dock never overlaps content
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }

  Widget _buildGreetingCard(BuildContext context, List<Donation> donations) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final totalServings = donations.fold<int>(0, (sum, d) => sum + d.servings);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      padding: const EdgeInsets.all(22),
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
          // Ambient decorative botanical background accent
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD2E7D6).withOpacity(0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(LucideIcons.soup, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
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
                        const Text(
                          '🌱',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified Donor',
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
              const SizedBox(height: 18),
              Text(
                '$greeting! 👋',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFD2E7D6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Every meal saved\nmakes a difference.',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  height: 1.22,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.heartHandshake, color: Color(0xFFD2E7D6), size: 15),
                    const SizedBox(width: 6),
                    Text(
                      '$totalServings total servings rescued by you',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFE8F4EC),
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
    );
  }

  Widget _buildActiveDonationBanner(BuildContext context, Donation donation) {
    return GestureDetector(
      onTap: () => context.push('/donor/track-donation', extra: donation),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.donorContainer.withOpacity(0.45),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.donorPrimary.withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.donorPrimary.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.donorPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(LucideIcons.bike, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Rider on the way!',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.donorOnContainer,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.donorPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'LIVE',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.donorPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    donation.foodName,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Track',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.donorPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(LucideIcons.chevronRight, color: AppColors.donorPrimary, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, List<Donation> donations) {
    final delivered = donations.where((d) => d.status == DonationStatus.delivered).length;
    final totalServings = donations.fold<int>(0, (sum, d) => sum + d.servings);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          _buildStatCard(
            context: context,
            value: '${donations.length}',
            label: 'Donations',
            icon: LucideIcons.packageCheck,
            containerColor: const Color(0xFFE8F4EC), // Pale Sage
            accentColor: AppColors.donorPrimary,
            textColor: const Color(0xFF1B4332),
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            context: context,
            value: '$delivered',
            label: 'Delivered',
            icon: LucideIcons.badgeCheck,
            containerColor: const Color(0xFFDDF0E4), // Mint Rosette
            accentColor: const Color(0xFF0D652D),
            textColor: const Color(0xFF0D652D),
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            context: context,
            value: '$totalServings',
            label: 'Meals',
            icon: LucideIcons.utensils,
            containerColor: const Color(0xFFFDF1E6), // Warm Apricot
            accentColor: const Color(0xFFA04E28),
            textColor: const Color(0xFFA04E28),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
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
                fontSize: 20,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDonationsState extends StatelessWidget {
  const _EmptyDonationsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.donorContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.packagePlus, size: 48, color: AppColors.donorPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            'No donations yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the "+" button in the dock to broadcast surplus food and connect with nearby NGO shelters.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationTile extends StatelessWidget {
  final Donation donation;
  const _DonationTile({required this.donation});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(donation.status);
    final statusContainerColor = _statusContainerColor(donation.status);
    final statusLabel = _statusLabel(donation.status);
    final statusIcon = _statusIcon(donation.status);
    final timeAgo = _timeAgo(donation.postedAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black.withOpacity(0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusContainerColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 5),
                    Text(
                      statusLabel,
                      style: GoogleFonts.plusJakartaSans(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                timeAgo,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textDisabled,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            donation.foodName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${donation.quantity} ${donation.unit}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '·  ${donation.servings} servings  ·  ${donation.category}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (donation.matchedNgo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.donorContainer.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.building2, size: 14, color: AppColors.donorPrimary),
                  const SizedBox(width: 6),
                  Text(
                    donation.matchedNgo!,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.donorOnContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(DonationStatus status) {
    switch (status) {
      case DonationStatus.pending: return const Color(0xFF8C6B00);
      case DonationStatus.matched: return const Color(0xFFA04E28);
      case DonationStatus.inTransit: return const Color(0xFF173752);
      case DonationStatus.delivered: return const Color(0xFF0D652D);
    }
  }

  Color _statusContainerColor(DonationStatus status) {
    switch (status) {
      case DonationStatus.pending: return const Color(0xFFFEF3D6);
      case DonationStatus.matched: return const Color(0xFFFDE4D0);
      case DonationStatus.inTransit: return const Color(0xFFD0E3EE);
      case DonationStatus.delivered: return const Color(0xFFD6F5E3);
    }
  }

  IconData _statusIcon(DonationStatus status) {
    switch (status) {
      case DonationStatus.pending: return LucideIcons.clock;
      case DonationStatus.matched: return LucideIcons.building2;
      case DonationStatus.inTransit: return LucideIcons.bike;
      case DonationStatus.delivered: return LucideIcons.badgeCheck;
    }
  }

  String _statusLabel(DonationStatus status) {
    switch (status) {
      case DonationStatus.pending: return 'PENDING';
      case DonationStatus.matched: return 'MATCHED';
      case DonationStatus.inTransit: return 'IN TRANSIT';
      case DonationStatus.delivered: return 'DELIVERED';
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.isNegative || diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
