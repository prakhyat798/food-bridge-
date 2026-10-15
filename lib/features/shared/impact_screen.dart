import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_wavy_header.dart';

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // NOTE: ImpactScreen is embedded as a tab body inside DonorHomeScreen's Scaffold.
    // Returning a plain CustomScrollView avoids a nested Scaffold.
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AnimatedWavyHeader(
            height: 300,
            backgroundColor: AppColors.accent,
            waveColor: Colors.white.withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.globe, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Your Impact',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Making the world better, one meal at a time.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildAnimatedCounterCard(
                context,
                title: 'Meals Rescued',
                endValue: 1284,
                icon: LucideIcons.utensils,
                color: AppColors.accent,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAnimatedCounterCard(
                      context,
                      title: 'Food Saved (kg)',
                      endValue: 450,
                      icon: LucideIcons.packageCheck,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAnimatedCounterCard(
                      context,
                      title: 'Deliveries',
                      endValue: 87,
                      icon: LucideIcons.bike,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildActivityTile(
                  context, 'Successfully rescued 50 meals', '2 hours ago', AppColors.accent),
              _buildActivityTile(
                  context, 'Delivered to Helping Hands', 'Yesterday', AppColors.primary),
              _buildActivityTile(
                  context, 'Reached 1000 meals milestone!', 'Last Week', AppColors.warning),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCounterCard(
    BuildContext context, {
    required String title,
    required int endValue,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: endValue),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  value.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: color,
                        height: 1,
                      ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, String title, String time, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(
        time,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textDisabled),
      ),
    );
  }
}
