import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class DockItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const DockItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

class MaterialYouDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<DockItem> items;
  final Color activeColor;
  final Color activeContainerColor;
  final VoidCallback? onCenterActionPressed;
  final IconData centerActionIcon;
  final String? centerActionTooltip;

  const MaterialYouDock({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
    this.activeColor = AppColors.donorPrimary,
    this.activeContainerColor = AppColors.donorContainer,
    this.onCenterActionPressed,
    this.centerActionIcon = LucideIcons.plus,
    this.centerActionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    // If center action is provided, we split items into left and right halves
    final hasCenterAction = onCenterActionPressed != null;
    final int splitIndex = items.length ~/ 2;
    final leftItems = hasCenterAction ? items.sublist(0, splitIndex) : items;
    final rightItems = hasCenterAction ? items.sublist(splitIndex) : <DockItem>[];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: activeColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Left items
          for (int i = 0; i < leftItems.length; i++)
            _buildDockButton(
              item: leftItems[i],
              isSelected: currentIndex == i,
              onTap: () => onItemSelected(i),
            ),

          // Center hero action button
          if (hasCenterAction) ...[
            _buildCenterHeroButton(),
            // Right items
            for (int i = 0; i < rightItems.length; i++)
              _buildDockButton(
                item: rightItems[i],
                isSelected: currentIndex == (splitIndex + i),
                onTap: () => onItemSelected(splitIndex + i),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDockButton({
    required DockItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeContainerColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? (item.activeIcon ?? item.icon) : item.icon,
              size: 22,
              color: isSelected ? activeColor : AppColors.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterHeroButton() {
    return Tooltip(
      message: centerActionTooltip ?? 'Action',
      child: GestureDetector(
        onTap: onCenterActionPressed,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                activeColor,
                Color.lerp(activeColor, Colors.black, 0.25)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: activeColor.withOpacity(0.38),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            centerActionIcon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
