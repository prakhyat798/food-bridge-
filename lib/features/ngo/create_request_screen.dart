import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _peopleController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Cooked Meals';
  double _urgency = 2.0;

  final List<String> _categories = [
    'Cooked Meals',
    'Raw Ingredients',
    'Packaged Food',
    'Beverages'
  ];

  @override
  void dispose() {
    _peopleController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_formKey.currentState?.validate() ?? true) {
      final peopleCount = int.tryParse(_peopleController.text.trim()) ?? 50;
      final requiredBy = _timeController.text.trim().isNotEmpty
          ? _timeController.text.trim()
          : 'Today, 8:00 PM';
      final urgencyText = _urgency == 3 ? 'High' : _urgency == 2 ? 'Normal' : 'Low';

      final newRequest = NgoRequest(
        id: 'r_${DateTime.now().millisecondsSinceEpoch}',
        ngoName: 'Helping Hands Foundation',
        category: _selectedCategory,
        peopleCount: peopleCount,
        requiredBy: requiredBy,
        urgency: urgencyText,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        status: 'open',
        distance: 1.5,
      );

      ref.read(ngoRequestsProvider.notifier).addRequest(newRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Request for $peopleCount people posted! Donors are being notified.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Request Food'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What do you need?',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Create a request to notify nearby donors.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // Category Chips
              Text('Food Category', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    backgroundColor: AppColors.surfaceVariant,
                    selectedColor: AppColors.accent.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.accent : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.accent : Colors.transparent,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _peopleController,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter number of people to feed';
                  }
                  final n = int.tryParse(val.trim());
                  if (n == null || n <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Number of People to Feed',
                  hintText: 'e.g., 50',
                  prefixIcon: Icon(LucideIcons.users),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Required By (Time)',
                  hintText: 'e.g., 8:00 PM today',
                  prefixIcon: Icon(LucideIcons.clock),
                ),
              ),
              const SizedBox(height: 24),

              Text('Urgency', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Slider(
                value: _urgency,
                min: 1,
                max: 3,
                divisions: 2,
                activeColor: _urgency == 3 ? AppColors.urgent : AppColors.accent,
                label: _urgency == 1 ? 'Low' : _urgency == 2 ? 'Normal' : 'High',
                onChanged: (val) => setState(() => _urgency = val),
              ),
              
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  hintText: 'e.g., specific dietary requirements...',
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Post Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
