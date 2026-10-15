import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class StepFoodCondition extends ConsumerStatefulWidget {
  const StepFoodCondition({super.key});

  @override
  ConsumerState<StepFoodCondition> createState() => _StepFoodConditionState();
}

class _StepFoodConditionState extends ConsumerState<StepFoodCondition>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<Map<String, dynamic>> _conditions = [
    {
      'title': 'Freshly Prepared',
      'desc': 'Cooked within the last 1–3 hours',
      'icon': LucideIcons.flame,
      'color': AppColors.donorPrimary,
    },
    {
      'title': 'Properly Stored (Cold)',
      'desc': 'Refrigerated immediately at < 4°C',
      'icon': LucideIcons.snowflake,
      'color': AppColors.riderPrimary,
    },
    {
      'title': 'Properly Stored (Room Temp)',
      'desc': 'Covered in dry, ambient containers',
      'icon': LucideIcons.box,
      'color': AppColors.ngoPrimary,
    },
    {
      'title': 'Packaged (Unopened)',
      'desc': 'Original sealed commercial packaging',
      'icon': LucideIcons.shieldCheck,
      'color': Color(0xFF34A853),
    },
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final draft = ref.watch(donationDraftProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Freshness & Shelf Life',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Determine algorithmic dispatch urgency for nearby shelters.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Condition Squircle List
          Text(
            'Current State',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _conditions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cond = _conditions[index];
              final isSelected = draft.condition == cond['title'];
              final color = cond['color'] as Color;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    ref.read(donationDraftProvider.notifier).update(condition: cond['title']);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : AppColors.border.withOpacity(0.6),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.18) : AppColors.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(cond['icon'] as IconData, color: isSelected ? color : AppColors.textSecondary, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cond['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isSelected ? color : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                cond['desc'] as String,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? color : AppColors.textDisabled,
                              width: 2,
                            ),
                            color: isSelected ? color : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(Icons.check, size: 14, color: Colors.white),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // Safe Consumption Window Slider Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Safe Consumption Window',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSliderColor(draft.consumptionWindowHours).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        '${draft.consumptionWindowHours.toInt()} Hours',
                        style: TextStyle(
                          color: _getSliderColor(draft.consumptionWindowHours),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _getSliderColor(draft.consumptionWindowHours),
                    inactiveTrackColor: AppColors.surfaceContainerHigh,
                    thumbColor: _getSliderColor(draft.consumptionWindowHours),
                    overlayColor: _getSliderColor(draft.consumptionWindowHours).withOpacity(0.15),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: draft.consumptionWindowHours,
                    min: 1,
                    max: 24,
                    divisions: 23,
                    onChanged: (val) {
                      ref.read(donationDraftProvider.notifier).update(consumptionWindowHours: val);
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 14,
                      color: _getSliderColor(draft.consumptionWindowHours),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        draft.consumptionWindowHours <= 4
                            ? 'Urgent Rescue: Prioritizes nearby couriers within 2 km radius.'
                            : 'Standard Window: Shelters can schedule pickup within regular hours.',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getSliderColor(draft.consumptionWindowHours),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSliderColor(double hours) {
    if (hours <= 3) return AppColors.urgent;
    if (hours <= 6) return AppColors.warning;
    return AppColors.donorPrimary;
  }
}
