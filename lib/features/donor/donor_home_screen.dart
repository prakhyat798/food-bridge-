import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../shared/impact_screen.dart';
import '../shared/widgets/notifications_sheet.dart';
import '../shared/widgets/material_you_dock.dart';
import 'widgets/request_card.dart';
import 'widgets/donor_dashboard_tab.dart';
import 'widgets/donor_profile_tab.dart';

class DonorHomeScreen extends ConsumerStatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  ConsumerState<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends ConsumerState<DonorHomeScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Cooked Meals',
    'Raw Ingredients',
    'Packaged Food',
    'Beverages',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasCeramic,
      appBar: AppBar(
        backgroundColor: AppColors.canvasCeramic,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.donorOnContainer),
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
            color: AppColors.donorOnContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: AppColors.donorOnContainer),
            onPressed: () => NotificationsSheet.show(context, role: 'donor'),
          )
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: MaterialYouDock(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        activeColor: AppColors.donorPrimary,
        activeContainerColor: AppColors.donorContainer,
        onCenterActionPressed: () => context.push('/donor/create-donation'),
        centerActionIcon: LucideIcons.plus,
        centerActionTooltip: 'Donate Food',
        items: const [
          DockItem(
            icon: LucideIcons.home,
            label: 'Home',
          ),
          DockItem(
            icon: LucideIcons.compass,
            label: 'Explore',
          ),
          DockItem(
            icon: LucideIcons.activity,
            label: 'Activity',
          ),
          DockItem(
            icon: LucideIcons.user,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return 'FoodBridge';
      case 1: return 'Explore Requests';
      case 2: return 'Your Activity';
      case 3: return 'Profile';
      default: return 'FoodBridge';
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return const DonorDashboardTab();
      case 1: return _buildExploreTab();
      case 2: return const ImpactScreen();
      case 3: return const DonorProfileTab();
      default: return const DonorDashboardTab();
    }
  }

  Widget _buildExploreTab() {
    final allRequests = ref.watch(ngoRequestsProvider);
    final filtered = allRequests.where((req) {
      final matchesSearch = _searchQuery.isEmpty ||
          req.ngoName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          req.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'All' || req.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Search NGO or food category...',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),

        // Filter chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final cat = _categories[i];
              final isSelected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedCategory = cat);
                },
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Request cards list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.searchX, size: 48, color: AppColors.textDisabled.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      Text('No requests found', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('Try adjusting your search or filters.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final req = filtered[i];
                    return RequestCard(
                      ngoName: req.ngoName,
                      title: '${req.category} for ${req.peopleCount} People',
                      quantity: '${req.peopleCount} People',
                      timeRequired: req.requiredBy,
                      distance: '${req.distance} km',
                      isUrgent: req.urgency == 'High',
                      onDonateTap: () => context.push('/donor/create-donation'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
