import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/communication_service.dart';

class DonationTrackingScreen extends StatelessWidget {
  final Donation donation;

  const DonationTrackingScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Track Donation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Donation Card
            _buildDonationInfoCard(context),
            const SizedBox(height: 24),

            // Status Timeline
            Text('Rescue Timeline', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildTimeline(context),
            const SizedBox(height: 24),

            // Rider card if assigned
            if (donation.riderId != null || donation.status == DonationStatus.inTransit || donation.status == DonationStatus.delivered)
              _buildRiderCard(context),

            const SizedBox(height: 24),

            // NGO Card
            if (donation.matchedNgo != null) _buildNgoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationInfoCard(BuildContext context) {
    final statusColor = _statusColor(donation.status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.08), statusColor.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(donation.status),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              if (donation.isUrgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.urgent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.urgent.withOpacity(0.4)),
                  ),
                  child: const Text(
                    '⚡ URGENT',
                    style: TextStyle(color: AppColors.urgent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(donation.foodName, style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoChip(context, LucideIcons.packageCheck, '${donation.quantity} ${donation.unit}'),
              const SizedBox(width: 8),
              _infoChip(context, LucideIcons.users, '${donation.servings} servings'),
            ],
          ),
          const SizedBox(height: 8),
          _infoChip(context, LucideIcons.tag, donation.category),
        ],
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final steps = [
      _TimelineStep(label: 'Donation Posted', icon: LucideIcons.packagePlus, isDone: true),
      _TimelineStep(label: 'Matched with NGO', icon: LucideIcons.building, isDone: donation.matchedNgo != null),
      _TimelineStep(
        label: 'Rider Assigned',
        icon: LucideIcons.bike,
        isDone: donation.status == DonationStatus.inTransit || donation.status == DonationStatus.delivered,
      ),
      _TimelineStep(
        label: 'In Transit',
        icon: LucideIcons.navigation,
        isDone: donation.status == DonationStatus.inTransit || donation.status == DonationStatus.delivered,
        isActive: donation.status == DonationStatus.inTransit,
      ),
      _TimelineStep(
        label: 'Delivered 🎉',
        icon: LucideIcons.checkCircle,
        isDone: donation.status == DonationStatus.delivered,
      ),
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isLast = i == steps.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: step.isDone
                        ? (step.isActive ? AppColors.primary : AppColors.accent)
                        : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.isDone ? (step.isActive ? AppColors.primary : AppColors.accent) : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Icon(step.icon,
                      size: 16,
                      color: step.isDone ? Colors.white : AppColors.textDisabled),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: step.isDone ? AppColors.accent.withOpacity(0.4) : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                step.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: step.isDone ? AppColors.textPrimary : AppColors.textDisabled,
                      fontWeight: step.isActive ? FontWeight.bold : null,
                    ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRiderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.bike, color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rider ID: ${donation.riderId ?? 'R-201'}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text('4.9 · FoodBridge Certified', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.phone, color: AppColors.primary),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.1)),
                tooltip: 'Call Rider',
                onPressed: () => CommunicationService.makePhoneCall('+919876543210'),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(LucideIcons.messageSquare, color: AppColors.primary),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.1)),
                tooltip: 'Message Rider',
                onPressed: () => CommunicationService.sendSms(
                  '+919876543210',
                  body: 'Hi Rider! Checking in on donation: ${donation.foodName}.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNgoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.building, color: AppColors.accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donation.matchedNgo!, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text('✅ Verified NGO', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(DonationStatus status) {
    switch (status) {
      case DonationStatus.pending: return AppColors.warning;
      case DonationStatus.matched: return AppColors.info;
      case DonationStatus.inTransit: return AppColors.primary;
      case DonationStatus.delivered: return AppColors.accent;
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
}

class _TimelineStep {
  final String label;
  final IconData icon;
  final bool isDone;
  final bool isActive;
  const _TimelineStep({required this.label, required this.icon, required this.isDone, this.isActive = false});
}
