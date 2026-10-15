import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import 'widgets/step_food_details.dart';
import 'widgets/step_food_condition.dart';
import 'widgets/step_logistics_priority.dart';
import 'widgets/ngo_selection_sheet.dart';

class CreateDonationScreen extends ConsumerStatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  ConsumerState<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends ConsumerState<CreateDonationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      final draft = ref.read(donationDraftProvider);
      if (draft.foodName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Please enter the food item name to continue.'),
              ],
            ),
            backgroundColor: AppColors.urgent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
      if (draft.quantity.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Please enter food quantity to continue.'),
              ],
            ),
            backgroundColor: AppColors.urgent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      // Finish and show NGO Selection Sheet
      _showNgoSelectionSheet(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      // Reset draft when backing out of the wizard on step 1
      ref.read(donationDraftProvider.notifier).reset();
      context.pop();
    }
  }

  void _showNgoSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => NgoSelectionSheet(
        onDonationConfirmed: () {
          if (mounted) {
            context.go('/donor/home');
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasCeramic,
      appBar: AppBar(
        backgroundColor: AppColors.canvasCeramic,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.donorOnContainer),
          onPressed: _prevStep,
        ),
        title: Text(
          'Donor Food Creation Wizard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.donorOnContainer,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // M3 3-Step Pill Stepper Header
          _buildM3StepperHeader(),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe to enforce validation
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: const [
                StepFoodDetails(),
                StepFoodCondition(),
                StepLogisticsPriority(),
              ],
            ),
          ),
          
          // Bottom CTA Pill
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.donorPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: _nextStep,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStep == _totalSteps - 1 ? '+ Broadcast Food Rescue' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentStep == _totalSteps - 1 ? LucideIcons.radio : LucideIcons.arrowRight,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildM3StepperHeader() {
    final steps = [
      {'num': '1', 'title': 'Food Details'},
      {'num': '2', 'title': 'Freshness'},
      {'num': '3', 'title': 'Dispatch'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            final isPassed = _currentStep > stepBefore;
            return Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isPassed ? AppColors.donorPrimary : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }

          final stepIdx = index ~/ 2;
          final isActive = _currentStep == stepIdx;
          final isCompleted = _currentStep > stepIdx;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.donorPrimary
                      : isActive
                          ? AppColors.ngoPrimary
                          : AppColors.surfaceContainerHigh,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.ngoPrimary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : Text(
                          steps[stepIdx]['num']!,
                          style: TextStyle(
                            color: isActive ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                Text(
                  steps[stepIdx]['title']!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ngoOnContainer,
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

