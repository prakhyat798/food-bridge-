import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class JobCard extends StatelessWidget {
  final String pickupDistance;
  final String dropDistance;
  final String estTime;
  final String foodQuantity;
  final String ngoName;
  final bool isUrgent;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const JobCard({
    super.key,
    required this.pickupDistance,
    required this.dropDistance,
    required this.estTime,
    required this.foodQuantity,
    required this.ngoName,
    required this.onAccept,
    required this.onDecline,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isUrgent 
            ? BorderSide(color: AppColors.urgent.withOpacity(0.5), width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUrgent) ...[
              Row(
                children: [
                  const Icon(LucideIcons.alertTriangle, color: AppColors.urgent, size: 16),
                  const SizedBox(width: 8),
                  Text('URGENT RESCUE', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.urgent)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
            ],
            
            // Route visualization
            Row(
              children: [
                Column(
                  children: [
                    const Icon(LucideIcons.home, color: AppColors.primary, size: 20),
                    Container(height: 30, width: 2, color: AppColors.border),
                    const Icon(LucideIcons.building, color: AppColors.accent, size: 20),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRoutePoint(context, 'Pickup', pickupDistance, 'Donor Location'),
                      const SizedBox(height: 16),
                      _buildRoutePoint(context, 'Drop-off', dropDistance, ngoName),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Job Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(context, LucideIcons.clock, estTime, 'Est. Time'),
                _buildMetric(context, LucideIcons.box, foodQuantity, 'Quantity'),
                _buildMetric(context, LucideIcons.bike, 'Bike/Car', 'Vehicle'),
              ],
            ),
            const SizedBox(height: 20),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUrgent ? AppColors.urgent : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Accept Job'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutePoint(BuildContext context, String label, String distance, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textDisabled)),
            Text(distance, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15)),
      ],
    );
  }

  Widget _buildMetric(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14)),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textDisabled)),
      ],
    );
  }
}
