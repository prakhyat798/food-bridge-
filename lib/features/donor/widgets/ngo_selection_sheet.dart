import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class NgoSelectionSheet extends ConsumerWidget {
  final VoidCallback? onDonationConfirmed;
  const NgoSelectionSheet({super.key, this.onDonationConfirmed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Select Destination', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(
              'How would you like to route this donation?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            _buildOptionCard(
              context,
              title: 'Smart Match',
              description: 'FoodBridge recommends suitable NGOs based on food type, location, and capacity.',
              icon: LucideIcons.sparkles,
              iconColor: AppColors.primary,
              isRecommended: true,
              onTap: () => _handleSmartMatch(context, ref),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              title: 'Select NGO',
              description: 'Search and choose a specific verified NGO from the list.',
              icon: LucideIcons.search,
              iconColor: AppColors.info,
              onTap: () => _handleSelectNgo(context, ref),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              title: 'Public Donation',
              description: 'Make the donation available to any suitable NGO nearby.',
              icon: LucideIcons.globe,
              iconColor: AppColors.accent,
              onTap: () => _handlePublicDonation(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSmartMatch(BuildContext context, WidgetRef ref) {
    final draft = ref.read(donationDraftProvider);
    final donationsNotifier = ref.read(donationsProvider.notifier);
    final draftNotifier = ref.read(donationDraftProvider.notifier);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Smart Match Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ngoMatchTile(ctx, 'Helping Hands Foundation', '98% match · 3.4 km', AppColors.accent, () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              _confirmDonation(
                context: context,
                draft: draft,
                donationsNotifier: donationsNotifier,
                draftNotifier: draftNotifier,
                ngoName: 'Helping Hands Foundation',
              );
            }),
            _ngoMatchTile(ctx, 'City Orphanage', '85% match · 5.1 km', AppColors.primary, () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              _confirmDonation(
                context: context,
                draft: draft,
                donationsNotifier: donationsNotifier,
                draftNotifier: draftNotifier,
                ngoName: 'City Orphanage',
              );
            }),
            _ngoMatchTile(ctx, 'Community Kitchen East', '72% match · 8.2 km', AppColors.warning, () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              _confirmDonation(
                context: context,
                draft: draft,
                donationsNotifier: donationsNotifier,
                draftNotifier: draftNotifier,
                ngoName: 'Community Kitchen East',
              );
            }),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              _confirmDonation(
                context: context,
                draft: draft,
                donationsNotifier: donationsNotifier,
                draftNotifier: draftNotifier,
                ngoName: 'Helping Hands Foundation',
              );
            },
            child: const Text('Confirm Top Match'),
          ),
        ],
      ),
    );
  }

  Widget _ngoMatchTile(BuildContext context, String name, String meta, Color color, VoidCallback? onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(LucideIcons.building, color: color, size: 20),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(meta, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textDisabled),
    );
  }

  void _handleSelectNgo(BuildContext context, WidgetRef ref) {
    final draft = ref.read(donationDraftProvider);
    final donationsNotifier = ref.read(donationsProvider.notifier);
    final draftNotifier = ref.read(donationDraftProvider.notifier);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select an NGO'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ngoMatchTile(ctx, 'Helping Hands Foundation', 'Verified · 3.4 km', AppColors.accent, () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              _confirmDonation(
                context: context,
                draft: draft,
                donationsNotifier: donationsNotifier,
                draftNotifier: draftNotifier,
                ngoName: 'Helping Hands Foundation',
              );
            }),
            _ngoMatchTile(ctx, 'City Orphanage', 'Verified · 5.1 km', AppColors.primary, () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              _confirmDonation(
                context: context,
                draft: draft,
                donationsNotifier: donationsNotifier,
                draftNotifier: draftNotifier,
                ngoName: 'City Orphanage',
              );
            }),
            _ngoMatchTile(ctx, 'Community Kitchen East', 'Verified · 8.2 km', AppColors.warning, () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              _confirmDonation(
                context: context,
                draft: draft,
                donationsNotifier: donationsNotifier,
                draftNotifier: draftNotifier,
                ngoName: 'Community Kitchen East',
              );
            }),
            _ngoMatchTile(ctx, 'Food for All Trust', 'Verified · 12 km', AppColors.info, () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              _confirmDonation(
                context: context,
                draft: draft,
                donationsNotifier: donationsNotifier,
                draftNotifier: draftNotifier,
                ngoName: 'Food for All Trust',
              );
            }),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _handlePublicDonation(BuildContext context, WidgetRef ref) {
    final draft = ref.read(donationDraftProvider);
    final donationsNotifier = ref.read(donationsProvider.notifier);
    final draftNotifier = ref.read(donationDraftProvider.notifier);

    Navigator.pop(context);
    _confirmDonation(
      context: context,
      draft: draft,
      donationsNotifier: donationsNotifier,
      draftNotifier: draftNotifier,
      ngoName: null,
    );
  }

  void _confirmDonation({
    required BuildContext context,
    required DonationDraft draft,
    required DonationsNotifier donationsNotifier,
    required DonationDraftNotifier draftNotifier,
    String? ngoName,
  }) {
    final isUrgent = draft.consumptionWindowHours <= 4.0;

    // Add real donation to state provider and sync to Supabase
    donationsNotifier.addDonation(
      Donation(
        id: 'd_${DateTime.now().millisecondsSinceEpoch}',
        foodName: draft.foodName.isNotEmpty ? draft.foodName : 'Surplus Meals',
        category: draft.category,
        quantity: draft.quantity.isNotEmpty ? draft.quantity : '1',
        unit: draft.unit,
        servings: draft.servings > 0 ? draft.servings : 1,
        condition: draft.condition,
        isUrgent: isUrgent,
        postedAt: DateTime.now(),
        status: ngoName != null ? DonationStatus.matched : DonationStatus.pending,
        matchedNgo: ngoName,
        riderId: null,
      ),
    );

    draftNotifier.reset();

    if (onDonationConfirmed != null) {
      onDonationConfirmed!();
    } else {
      context.go('/donor/home');
    }
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    bool isRecommended = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isRecommended ? iconColor.withOpacity(0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended ? iconColor.withOpacity(0.3) : AppColors.border,
            width: isRecommended ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleLarge),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: iconColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'RECOMMENDED',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
