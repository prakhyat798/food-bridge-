import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class StepLogisticsPriority extends ConsumerStatefulWidget {
  const StepLogisticsPriority({super.key});

  @override
  ConsumerState<StepLogisticsPriority> createState() => _StepLogisticsPriorityState();
}

class _StepLogisticsPriorityState extends ConsumerState<StepLogisticsPriority>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _declarationAccepted = true;

  final List<Map<String, dynamic>> _preferences = [
    {
      'label': 'FoodBridge Rider',
      'icon': LucideIcons.bike,
    },
    {
      'label': 'NGO Pickup',
      'icon': LucideIcons.building,
    },
    {
      'label': 'I will drop it off',
      'icon': LucideIcons.footprints,
    },
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final draft = ref.watch(donationDraftProvider);
    final isUrgent = draft.consumptionWindowHours <= 4.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Logistics & Priority',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Review AI-calculated dispatch priority and delivery preferences.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Rescue Priority Card (Material You 24dp Squircle)
          _buildPriorityCard(context, isUrgent, draft.consumptionWindowHours),
          const SizedBox(height: 24),

          // Pickup Preference Pill Chips
          Text(
            'Pickup Preference',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _preferences.map((pref) {
                final label = pref['label'] as String;
                final icon = pref['icon'] as IconData;
                final isSelected = draft.pickupPreference == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: FilterChip(
                    avatar: Icon(
                      icon,
                      size: 16,
                      color: isSelected ? AppColors.donorOnContainer : AppColors.textSecondary,
                    ),
                    label: Text(label),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(donationDraftProvider.notifier).update(pickupPreference: label);
                      }
                    },
                    backgroundColor: AppColors.surfaceContainer,
                    selectedColor: AppColors.donorContainer,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.donorOnContainer : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(
                        color: isSelected ? AppColors.donorPrimary.withOpacity(0.4) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 28),

          // Safety Declaration Squircle Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _declarationAccepted,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  activeColor: AppColors.donorPrimary,
                  onChanged: (val) => setState(() => _declarationAccepted = val ?? true),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Donor Quality & Hygiene Pledge',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.donorOnContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'I certify that this food was prepared with hygienic safety standards and is completely suitable for community shelter consumption.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityCard(BuildContext context, bool isUrgent, double hours) {
    final themeColor = isUrgent ? AppColors.ngoPrimary : AppColors.donorPrimary;
    final containerColor = isUrgent ? AppColors.ngoContainer : AppColors.donorContainer;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: containerColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUrgent ? LucideIcons.alertTriangle : LucideIcons.checkCircle2,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority: ${isUrgent ? 'URGENT DISPATCH' : 'STANDARD RESCUE'}',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      isUrgent ? 'Algorithmic fast-track for nearby shelters' : 'Normal scheduled shelter routing',
                      style: TextStyle(
                        color: themeColor.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: themeColor.withOpacity(0.2)),
          const SizedBox(height: 8),
          _buildLogisticsRow('Remaining Freshness Window', '${hours.toInt()}h 00m', themeColor),
          _buildLogisticsRow('Estimated Courier Transit', '18 mins', AppColors.textPrimary),
          _buildLogisticsRow('Pickup Preparation Overhead', '10 mins', AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildLogisticsRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
