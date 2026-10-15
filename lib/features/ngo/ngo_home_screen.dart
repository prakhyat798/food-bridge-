import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../shared/widgets/notifications_sheet.dart';
import '../shared/widgets/material_you_dock.dart';

class NgoHomeScreen extends ConsumerStatefulWidget {
  const NgoHomeScreen({super.key});

  @override
  ConsumerState<NgoHomeScreen> createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends ConsumerState<NgoHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasCeramic,
      appBar: AppBar(
        backgroundColor: AppColors.canvasCeramic,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.ngoOnContainer),
          tooltip: 'Back to Role Hub',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/role-selection');
            }
          },
        ),
        title: Text(
          _getTitle(),
          style: const TextStyle(
            color: AppColors.ngoOnContainer,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: AppColors.ngoOnContainer),
            onPressed: () => NotificationsSheet.show(context, role: 'ngo'),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/ngo/create-request'),
              backgroundColor: AppColors.ngoPrimary,
              foregroundColor: Colors.white,
              icon: const Icon(LucideIcons.edit3),
              label: const Text('Request Food'),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            )
          : null,
      bottomNavigationBar: MaterialYouDock(
        currentIndex: _currentIndex,
        onItemSelected: (index) => setState(() => _currentIndex = index),
        activeColor: AppColors.ngoPrimary,
        activeContainerColor: AppColors.ngoContainer,
        items: const [
          DockItem(icon: LucideIcons.radar, label: 'Radar'),
          DockItem(icon: LucideIcons.fileText, label: 'Requests'),
          DockItem(icon: LucideIcons.heart, label: 'Donations'),
          DockItem(icon: LucideIcons.activity, label: 'Impact'),
          DockItem(icon: LucideIcons.user, label: 'Profile'),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Shelter Dispatch Radar';
      case 1:
        return 'My Requests';
      case 2:
        return 'Incoming Donations';
      case 3:
        return 'Impact';
      case 4:
        return 'Profile';
      default:
        return 'Shelter Dispatch Radar';
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const _NgoDashboardHome();
      case 1:
        return const _NgoRequestsTab();
      case 2:
        return const _NgoDonationsTab();
      case 3:
        return const _NgoImpactTab();
      case 4:
        return const _NgoProfileTab();
      default:
        return const _NgoDashboardHome();
    }
  }
}

// ────────── Home Tab: Dispatch Radar ──────────
class _NgoDashboardHome extends ConsumerStatefulWidget {
  const _NgoDashboardHome();

  @override
  ConsumerState<_NgoDashboardHome> createState() => _NgoDashboardHomeState();
}

class _NgoDashboardHomeState extends ConsumerState<_NgoDashboardHome> {
  bool _alertDismissed = false;
  bool _claimed = false;

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(ngoRequestsProvider);
    final donations = ref.watch(donationsProvider);
    final incomingList = donations
        .where((d) => d.status == DonationStatus.pending || d.status == DonationStatus.matched)
        .toList();
    final activeDonation = incomingList.isNotEmpty ? incomingList.first : null;

    return CustomScrollView(
      slivers: [
        // 1. Incoming Surplus Alert Hero Card (Scene 3 in Blueprint)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: _buildIncomingSurplusCard(activeDonation),
          ),
        ),

        // 2. Animated Concentric Pulse Radar Graphic
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: _ConcentricRadarWidget(),
          ),
        ),

        // 3. Section Title & Active Requests
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Community Needs Queue',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.ngoContainer,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    '${requests.length} Active',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ngoOnContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _NgoRequestTile(request: requests[i]),
            childCount: requests.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildIncomingSurplusCard(Donation? donation) {
    if (_alertDismissed || donation == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.info, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Radar listening for nearby food surplus...',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            if (_alertDismissed)
              TextButton(
                onPressed: () => setState(() => _alertDismissed = false),
                child: const Text('Reset Alert', style: TextStyle(color: AppColors.ngoPrimary)),
              ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.ngoAlertBanner, // Warm apricot #FCEADE
        borderRadius: BorderRadius.circular(28), // 28dp squircle
        boxShadow: [
          BoxShadow(
            color: AppColors.ngoPrimary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Food badge & Distance pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.ngoContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.soup_kitchen_rounded,
                  color: AppColors.ngoPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        '⚡ Real-time Dispatch Alert',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ngoPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.ngoPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  '1.8 km away',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ngoOnContainer,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Headline
          Text(
            'Incoming Surplus: ${donation.servings} Meals',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.ngoOnContainer,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),

          // Sub-info: Shelf life countdown & food details
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 14, color: AppColors.ngoPrimary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${donation.condition} · ${donation.foodName} (${donation.quantity} ${donation.unit})',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A3E22),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Dual Action Buttons: [ Decline ] and [ Claim & Request Rider ]
          if (_claimed || donation.status == DonationStatus.matched)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF34A853),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Claimed! Matching Volunteer Courier...',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                // Decline Button
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.border.withOpacity(0.8)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      onPressed: () => setState(() => _alertDismissed = true),
                      child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Claim & Request Rider Button
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ngoPrimary, // Terracotta #A04E28
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      onPressed: () {
                        ref.read(donationsProvider.notifier).updateDonationStatus(
                              donation.id,
                              DonationStatus.matched,
                              matchedNgo: 'Helping Hands Foundation',
                            );
                        setState(() => _claimed = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🎉 Claimed ${donation.foodName}! Algorithmic rider dispatched.'),
                            backgroundColor: AppColors.ngoPrimary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        'Claim & Request Rider',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 14),

          // Pagination Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.ngoPrimary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.ngoPrimary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.ngoPrimary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────── Concentric Animated Pulse Radar Widget ──────────
class _ConcentricRadarWidget extends StatefulWidget {
  const _ConcentricRadarWidget();

  @override
  State<_ConcentricRadarWidget> createState() => _ConcentricRadarWidgetState();
}

class _ConcentricRadarWidgetState extends State<_ConcentricRadarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Radar pulse graphics
          SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: _radarController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Concentric Wave 3 (Outer)
                    _buildRadarWave(180, (_radarController.value + 0.6) % 1.0),
                    // Concentric Wave 2 (Middle)
                    _buildRadarWave(130, (_radarController.value + 0.3) % 1.0),
                    // Concentric Wave 1 (Inner)
                    _buildRadarWave(80, _radarController.value),

                    // Central Shelter Node
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.ngoPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ngoPrimary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.building,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    // Perimeter Volunteer Rider Pulse Node (Top-Right)
                    Positioned(
                      top: 18,
                      right: 48,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.riderPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.riderPrimary.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.bike,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),

                    // Perimeter Donor Kitchen Node (Bottom-Left)
                    Positioned(
                      bottom: 24,
                      left: 56,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.donorPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.donorPrimary.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.utensils,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Label below radar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF34A853),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Algorithmic Radar: 3 Courier Volunteers Active',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ngoOnContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadarWave(double maxSize, double progress) {
    final size = maxSize * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.ngoContainer.withOpacity(opacity * 0.35),
        border: Border.all(
          color: AppColors.ngoPrimary.withOpacity(opacity * 0.5),
          width: 1.5,
        ),
      ),
    );
  }
}

// ────────── Requests Tab ──────────
class _NgoRequestsTab extends ConsumerWidget {
  const _NgoRequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(ngoRequestsProvider);
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.fileText, size: 56, color: AppColors.textDisabled.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No requests yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Tap "Request Food" to post a need.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 100),
      itemCount: requests.length,
      itemBuilder: (context, i) => _NgoRequestTile(request: requests[i]),
    );
  }
}

class _NgoRequestTile extends StatelessWidget {
  final NgoRequest request;
  const _NgoRequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    final urgencyColor = request.urgency == 'High'
        ? AppColors.urgent
        : request.urgency == 'Normal'
            ? AppColors.warning
            : AppColors.accent;

    final statusColor = request.status == 'matched' ? AppColors.accent : AppColors.ngoPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${request.urgency} Urgency',
                  style: TextStyle(color: urgencyColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(request.category, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(LucideIcons.users, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('${request.peopleCount} people', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 16),
              const Icon(LucideIcons.clock, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(request.requiredBy, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────── Donations Tab ──────────
class _NgoDonationsTab extends ConsumerWidget {
  const _NgoDonationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donations = ref.watch(donationsProvider);
    if (donations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.packagePlus, size: 56, color: AppColors.textDisabled.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No incoming donations', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const Text('Donations from nearby donors will appear here in real time.', textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 100),
      itemCount: donations.length,
      itemBuilder: (context, i) {
        final d = donations[i];
        final color = d.status == DonationStatus.delivered
            ? const Color(0xFF34A853)
            : d.status == DonationStatus.inTransit
                ? AppColors.riderPrimary
                : d.status == DonationStatus.matched
                    ? AppColors.ngoPrimary
                    : AppColors.warning;

        final statusStr = d.status == DonationStatus.delivered
            ? 'Delivered'
            : d.status == DonationStatus.inTransit
                ? 'In Transit'
                : d.status == DonationStatus.matched
                    ? 'Matched'
                    : 'Pending';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.packageCheck, color: color),
            ),
            title: Text(d.foodName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${d.quantity} ${d.unit} · ${d.servings} servings', style: Theme.of(context).textTheme.bodySmall),
                if (d.matchedNgo != null) ...[
                  const SizedBox(height: 2),
                  Text('Allocated: ${d.matchedNgo}', style: const TextStyle(color: AppColors.ngoPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                statusStr,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ────────── Impact Tab ──────────
class _NgoImpactTab extends StatelessWidget {
  const _NgoImpactTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.ngoContainer,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.ngoPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.globe, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Community Relief', style: TextStyle(color: AppColors.ngoOnContainer, fontSize: 13, fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text('4,820 Meals Served', style: TextStyle(color: AppColors.ngoOnContainer, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Metrics Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard(context, '38', 'Active Requests', LucideIcons.fileText, AppColors.ngoPrimary)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, '210', 'Rescued Meals', LucideIcons.heart, const Color(0xFF34A853))),
            ],
          ),
          const SizedBox(width: 12),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(context, '156', 'Deliveries Done', LucideIcons.bike, AppColors.riderPrimary)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, '98%', 'Acceptance Rate', LucideIcons.star, AppColors.warning)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ────────── Profile Tab ──────────
class _NgoProfileTab extends ConsumerWidget {
  const _NgoProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSession = ref.watch(userSessionProvider);
    final displayName = userSession.name.isNotEmpty ? userSession.name : 'Helping Hands Shelter';
    final displayPhone = userSession.phone.isNotEmpty ? '+91 ${userSession.phone} · Mumbai' : 'Verified Relief NGO · Mumbai, India';

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            decoration: const BoxDecoration(
              color: AppColors.ngoContainer,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.ngoPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.building, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(color: AppColors.ngoOnContainer, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(displayPhone, style: const TextStyle(color: Color(0xFF7A3E22), fontSize: 14)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text('✅ Verified Organization', style: TextStyle(color: AppColors.ngoOnContainer, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildTile(context, LucideIcons.fileText, 'Organization Details', 'Update info & documents'),
          _buildTile(context, LucideIcons.mapPin, 'Service Area', 'Manage coverage zones'),
          _buildTile(context, LucideIcons.bell, 'Notifications', 'Manage alerts & reminders'),
          _buildTile(context, LucideIcons.shield, 'Verification', 'Compliance & certificates'),
          _buildTile(context, LucideIcons.helpCircle, 'Help & Support', 'FAQs and contact'),
          const Divider(height: 1),
          _buildTile(
            context,
            LucideIcons.logOut,
            'Sign Out',
            'Log out of FoodBridge',
            color: AppColors.urgent,
            onTap: () async {
              await ref.read(userSessionProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, String subtitle, {Color? color, VoidCallback? onTap}) {
    final tileColor = color ?? AppColors.textPrimary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: tileColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: tileColor, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: tileColor)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(LucideIcons.chevronRight, color: AppColors.textDisabled, size: 18),
      onTap: onTap ?? () {},
    );
  }
}
