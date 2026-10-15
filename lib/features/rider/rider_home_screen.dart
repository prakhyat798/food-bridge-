import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../shared/widgets/notifications_sheet.dart';
import '../shared/widgets/material_you_dock.dart';
import 'widgets/job_card.dart';

class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  int _currentIndex = 0;
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () => NotificationsSheet.show(context, role: 'rider'),
          ),
          if (_currentIndex == 0 || _currentIndex == 1)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Switch(
                value: _isOnline,
                onChanged: (val) => setState(() => _isOnline = val),
                activeColor: AppColors.accent,
              ),
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: MaterialYouDock(
        currentIndex: _currentIndex,
        onItemSelected: (index) => setState(() => _currentIndex = index),
        activeColor: AppColors.riderPrimary,
        activeContainerColor: AppColors.riderContainer,
        items: const [
          DockItem(icon: LucideIcons.home, label: 'Home'),
          DockItem(icon: LucideIcons.briefcase, label: 'Jobs'),
          DockItem(icon: LucideIcons.map, label: 'Active'),
          DockItem(icon: LucideIcons.indianRupee, label: 'Earnings'),
          DockItem(icon: LucideIcons.user, label: 'Profile'),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return 'FoodBridge';
      case 1: return 'Available Jobs';
      case 2: return 'Active Delivery';
      case 3: return 'Earnings';
      case 4: return 'Profile';
      default: return 'FoodBridge';
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _RiderDashboardHome(isOnline: _isOnline, onToggle: (val) => setState(() => _isOnline = val));
      case 1: return _RiderJobsTab(isOnline: _isOnline);
      case 2: return _RiderActiveTab();
      case 3: return const _RiderEarningsTab();
      case 4: return const _RiderProfileTab();
      default: return const SizedBox();
    }
  }
}

// ────────── Home Tab ──────────
class _RiderDashboardHome extends ConsumerWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;

  const _RiderDashboardHome({required this.isOnline, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(riderStatsProvider);
    final jobs = ref.watch(riderJobsProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildStatusCard(context, stats)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text('Quick Stats', style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        SliverToBoxAdapter(child: _buildStatsRow(context, stats)),
        if (isOnline) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Text('Nearby Jobs', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('${jobs.length} available', style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          if (jobs.isNotEmpty)
            SliverToBoxAdapter(
              child: JobCard(
                pickupDistance: jobs.first.pickupDistance,
                dropDistance: jobs.first.dropDistance,
                estTime: jobs.first.estTime,
                foodQuantity: jobs.first.foodQuantity,
                ngoName: jobs.first.ngoName,
                isUrgent: jobs.first.isUrgent,
                onAccept: () => context.push('/rider/active-delivery'),
                onDecline: () {},
              ),
            )
          else
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'No rescue jobs available right now.\nYou will be notified when a donor posts food nearby.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
        ] else
          SliverToBoxAdapter(child: _buildOfflineBanner(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, RiderStats stats) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOnline
              ? [AppColors.accent, const Color(0xFF059669)]
              : [AppColors.textSecondary, const Color(0xFF475569)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isOnline ? 'You\'re Online 🟢' : 'You\'re Offline 🔴',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(isOnline ? 'Ready to rescue food!' : 'Go online to earn',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              Switch(
                value: isOnline,
                onChanged: onToggle,
                activeColor: Colors.white,
                activeTrackColor: Colors.white30,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white24,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _todayStat(context, '₹${stats.todayEarnings.toStringAsFixed(0)}', 'Today'),
              Container(width: 1, height: 32, color: Colors.white30, margin: const EdgeInsets.symmetric(horizontal: 16)),
              _todayStat(context, '${stats.totalDeliveries}', 'Deliveries'),
              Container(width: 1, height: 32, color: Colors.white30, margin: const EdgeInsets.symmetric(horizontal: 16)),
              _todayStat(context, '${stats.rating}⭐', 'Rating'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _todayStat(BuildContext context, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, RiderStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatChip(context, '${stats.mealsRescued}', 'Meals Rescued', LucideIcons.utensils, AppColors.primary),
          const SizedBox(width: 12),
          _buildStatChip(context, '${stats.totalDeliveries}', 'Total Jobs', LucideIcons.briefcase, AppColors.warning),
          const SizedBox(width: 12),
          _buildStatChip(context, '${stats.rating}', 'Rating', LucideIcons.star, AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.powerOff, size: 48, color: AppColors.textDisabled.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text('Go online to start', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Toggle online to see available food rescue jobs near you.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ────────── Jobs Tab ──────────
class _RiderJobsTab extends ConsumerWidget {
  final bool isOnline;
  const _RiderJobsTab({required this.isOnline});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(riderJobsProvider);

    if (!isOnline) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.powerOff, size: 64, color: AppColors.textDisabled.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('You are offline', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Go online to start receiving rescue jobs.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 100),
      itemCount: jobs.length,
      itemBuilder: (context, i) {
        final job = jobs[i];
        return JobCard(
          pickupDistance: job.pickupDistance,
          dropDistance: job.dropDistance,
          estTime: job.estTime,
          foodQuantity: job.foodQuantity,
          ngoName: job.ngoName,
          isUrgent: job.isUrgent,
          onAccept: () => context.push('/rider/active-delivery'),
          onDecline: () {},
        );
      },
    );
  }
}

// ────────── Active Tab ──────────
class _RiderActiveTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.map, size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text('No Active Delivery', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Accept a job from the Jobs tab to start a delivery, or explore the live delivery console below.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/rider/active-delivery'),
              icon: const Icon(LucideIcons.navigation, size: 18),
              label: const Text('Launch Active Delivery Console'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────── Earnings Tab ──────────
class _RiderEarningsTab extends ConsumerWidget {
  const _RiderEarningsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(riderStatsProvider);
    final weeklyData = [1200.0, 850.0, 1450.0, 340.5, 0.0, 0.0, 0.0];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total earnings card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.warning, Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This Week', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  '₹${weeklyData.fold(0.0, (a, b) => a + b).toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Today: ₹${stats.todayEarnings.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bar chart
          Text('Daily Breakdown', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final maxVal = weeklyData.reduce((a, b) => a > b ? a : b);
                final fraction = maxVal == 0 ? 0.0 : weeklyData[i] / maxVal;
                final isToday = i == 3;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (weeklyData[i] > 0)
                      Text('₹${weeklyData[i].toInt()}', style: TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: 32,
                      height: (fraction * 100).clamp(4.0, 100.0),
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.warning : AppColors.warning.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(days[i], style: TextStyle(fontSize: 11, color: isToday ? AppColors.warning : AppColors.textDisabled, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          // Recent transactions
          Text('Recent Payouts', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...[
            ('Wed · 2 deliveries', '₹1,450', AppColors.accent),
            ('Tue · 1 delivery', '₹850', AppColors.accent),
            ('Mon · 2 deliveries', '₹1,200', AppColors.accent),
          ].map((t) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.$1, style: Theme.of(context).textTheme.bodyLarge),
                trailing: Text(t.$2, style: TextStyle(color: t.$3, fontWeight: FontWeight.bold, fontSize: 16)),
              )),
        ],
      ),
    );
  }
}

// ────────── Profile Tab ──────────
class _RiderProfileTab extends ConsumerWidget {
  const _RiderProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(riderStatsProvider);
    final userSession = ref.watch(userSessionProvider);
    final displayName = userSession.name.isNotEmpty ? userSession.name : 'Courier Partner';
    final displayPhone = userSession.phone.isNotEmpty ? '+91 ${userSession.phone} · Mumbai' : 'Rider · R-201 · Mumbai, India';

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.warning, Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                  ),
                  child: const Icon(LucideIcons.user, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(displayPhone, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _chip('${stats.rating} ⭐'),
                    const SizedBox(width: 8),
                    _chip('${stats.totalDeliveries} Deliveries'),
                  ],
                ),
              ],
            ),
          ),
          _buildTile(context, LucideIcons.user, 'Edit Profile', 'Update personal info'),
          _buildTile(context, LucideIcons.car, 'Vehicle Details', 'Bike/car registration'),
          _buildTile(context, LucideIcons.dollarSign, 'Payment Settings', 'UPI & bank account'),
          _buildTile(context, LucideIcons.bell, 'Notifications', 'Job alerts'),
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

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, String subtitle, {Color? color, VoidCallback? onTap}) {
    final tileColor = color ?? AppColors.textPrimary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: tileColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: tileColor, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: tileColor)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(LucideIcons.chevronRight, color: AppColors.textDisabled, size: 18),
      onTap: onTap ?? () {},
    );
  }
}

