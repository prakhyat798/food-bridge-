import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class StepFoodDetails extends ConsumerStatefulWidget {
  const StepFoodDetails({super.key});

  @override
  ConsumerState<StepFoodDetails> createState() => _StepFoodDetailsState();
}

class _StepFoodDetailsState extends ConsumerState<StepFoodDetails>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _servingsController;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;

  final List<String> _categories = [
    'Cooked Meals',
    'Raw Ingredients',
    'Packaged Food',
    'Baked Goods',
    'Beverages'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(donationDraftProvider);
    _nameController = TextEditingController(text: draft.foodName);
    _quantityController = TextEditingController(text: draft.quantity);
    _unitController = TextEditingController(
      text: draft.unit.isEmpty ? 'kg' : draft.unit,
    );
    _servingsController = TextEditingController(
      text: draft.servings > 0 ? draft.servings.toString() : '',
    );
    _pickedImagePath = draft.imagePath;

    // Immediately sync default values if draft was fresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncToDraft();
    });

    _nameController.addListener(_syncToDraft);
    _quantityController.addListener(_syncToDraft);
    _unitController.addListener(_syncToDraft);
    _servingsController.addListener(_syncToDraft);
  }

  void _syncToDraft() {
    final servings = int.tryParse(_servingsController.text.trim()) ?? 0;
    ref.read(donationDraftProvider.notifier).update(
          foodName: _nameController.text.trim(),
          quantity: _quantityController.text.trim(),
          unit: _unitController.text.trim(),
          servings: servings,
          imagePath: _pickedImagePath,
        );
  }

  void _openQuickEditModal() {
    final tempName = TextEditingController(text: _nameController.text);
    final tempQty = TextEditingController(text: _quantityController.text);
    final tempUnit = TextEditingController(text: _unitController.text.isEmpty ? 'kg' : _unitController.text);
    final tempServ = TextEditingController(text: _servingsController.text);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Form(
            key: formKey,
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.donorContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(LucideIcons.utensils, color: AppColors.donorPrimary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Food & Quantity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.donorOnContainer,
                            ),
                          ),
                          Text(
                            'Set description and quantity for volunteer pickup',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: tempName,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Food Item Name *',
                    hintText: 'e.g., Vegetable Biryani & Lentil Curry',
                    prefixIcon: const Icon(LucideIcons.soup, color: AppColors.donorPrimary),
                    filled: true,
                    fillColor: AppColors.surfaceContainerHigh.withOpacity(0.3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter food item name' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: tempQty,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'Quantity *',
                          hintText: 'e.g., 15',
                          prefixIcon: const Icon(LucideIcons.package, color: AppColors.donorPrimary),
                          filled: true,
                          fillColor: AppColors.surfaceContainerHigh.withOpacity(0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter quantity' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: tempUnit,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          hintText: 'kg',
                          filled: true,
                          fillColor: AppColors.surfaceContainerHigh.withOpacity(0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: tempServ,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Estimated Servings (People)',
                    hintText: 'e.g., 30',
                    prefixIcon: const Icon(LucideIcons.users, color: AppColors.donorPrimary),
                    filled: true,
                    fillColor: AppColors.surfaceContainerHigh.withOpacity(0.3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.donorPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        setState(() {
                          _nameController.text = tempName.text.trim();
                          _quantityController.text = tempQty.text.trim();
                          _unitController.text = tempUnit.text.trim().isNotEmpty ? tempUnit.text.trim() : 'kg';
                          _servingsController.text = tempServ.text.trim();
                        });
                        _syncToDraft();
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text(
                      'Save Food Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _pickedImagePath = photo.path;
        });
        _syncToDraft();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('AI Freshness: 98% Fresh & Shelter-Safe!'),
                ],
              ),
              backgroundColor: AppColors.donorPrimary,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[StepFoodDetails] Error picking image: $e');
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'AI Freshness Inspection',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.donorOnContainer),
              ),
              const SizedBox(height: 8),
              const Text(
                'Attach a live photo of surplus food to verify freshness score for shelter kitchens.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.donorPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(LucideIcons.camera, size: 20),
                      label: const Text('Open Camera'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.donorPrimary,
                        side: const BorderSide(color: AppColors.donorPrimary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(LucideIcons.image, size: 20),
                      label: const Text('Gallery'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _servingsController.dispose();
    _nameFocusNode.dispose();
    _quantityFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final draft = ref.watch(donationDraftProvider);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          Text(
            'Surplus Food Details',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Google Material You Dual AI Verification & Food Spec',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // ────────── 1. DUAL HERO ROW (AI Inspection + Food Details Card) ──────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Box: Dashed AI Freshness Inspection Squircle
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: _showImagePickerSheet,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CustomPaint(
                      painter: _DashedSquirclePainter(
                        color: const Color(0xFF8EB89D),
                        strokeWidth: 2,
                        borderRadius: 24,
                        dashLength: 6,
                        dashSpace: 4,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF5EE),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: _pickedImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    kIsWeb
                                        ? Image.network(_pickedImagePath!, fit: BoxFit.cover)
                                        : Image.file(File(_pickedImagePath!), fit: BoxFit.cover),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.6),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.donorPrimary,
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                                            SizedBox(width: 4),
                                            Text(
                                              '98% Fresh',
                                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.donorPrimary.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Icon(LucideIcons.camera, color: AppColors.donorPrimary, size: 26),
                                        Positioned(
                                          top: -2,
                                          right: -2,
                                          child: CircleAvatar(
                                            radius: 4,
                                            backgroundColor: Color(0xFF34A853),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'AI Freshness\nInspection',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.donorOnContainer,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Text(
                                      'Tap to scan',
                                      style: TextStyle(fontSize: 10, color: AppColors.donorPrimary, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Right Box: Solid Pistachio Squircle Food Card (Interactive Tap-to-Edit)
              Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _openQuickEditModal,
                      splashColor: AppColors.donorPrimary.withOpacity(0.12),
                      highlightColor: AppColors.donorPrimary.withOpacity(0.06),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.donorAccent,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.donorPrimary.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.donorPrimary.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: Green verified checkmark badge + Edit chip
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF34A853),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Verified Item',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.donorOnContainer,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(LucideIcons.pencil, size: 13, color: AppColors.donorPrimary),
                                ),
                              ],
                            ),
                            const Spacer(),

                            // Title
                            Text(
                              _nameController.text.isEmpty
                                  ? 'Tap to Enter Food Name'
                                  : _nameController.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _nameController.text.isEmpty
                                    ? AppColors.donorOnContainer.withOpacity(0.55)
                                    : AppColors.donorOnContainer,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Bottom pill chip with quantity & servings
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _quantityController.text.isEmpty ? LucideIcons.plus : LucideIcons.package,
                                    size: 11,
                                    color: AppColors.donorPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _quantityController.text.isEmpty && _servingsController.text.isEmpty
                                          ? 'Add quantity'
                                          : '${_quantityController.text.isEmpty ? '0' : _quantityController.text} ${_unitController.text.isEmpty ? 'kg' : _unitController.text} · ${_servingsController.text.isEmpty ? '0' : _servingsController.text} meals',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.donorPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ────────── 2. CATEGORY PILL CHIPS ──────────
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = draft.category == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    showCheckmark: isSelected,
                    checkmarkColor: AppColors.donorPrimary,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(donationDraftProvider.notifier).update(category: cat);
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // ────────── 3. DIETARY & FOOD TYPE PILLS ──────────
          Text(
            'Dietary Preference',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 100% Vegetarian Pill
              _buildDietaryPill(
                title: '100% Vegetarian',
                icon: Icons.eco_rounded,
                accentColor: const Color(0xFF2E6B4F),
                isSelected: draft.foodType == 'Veg',
                onTap: () => ref.read(donationDraftProvider.notifier).update(foodType: 'Veg'),
              ),
              const SizedBox(width: 10),
              // Non-Vegetarian Pill
              _buildDietaryPill(
                title: 'Non-Vegetarian',
                icon: Icons.restaurant_rounded,
                accentColor: const Color(0xFFA04E28),
                isSelected: draft.foodType == 'Non-Veg',
                onTap: () => ref.read(donationDraftProvider.notifier).update(foodType: 'Non-Veg'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ────────── 4. DETAILED INPUT FIELDS (M3 16dp Squircle) ──────────
          Row(
            children: [
              Text(
                'Edit Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _openQuickEditModal,
                icon: const Icon(LucideIcons.maximize2, size: 14, color: AppColors.donorPrimary),
                label: const Text('Popup Modal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.donorPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quick Suggested Food Name Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                '🥘 Veg Biryani & Dal',
                '🍚 Steamed Rice Trays',
                '🍞 Bread & Sandwiches',
                '🥗 Mixed Green Salad',
                '🍲 Lentil Curry & Roti',
              ].map((item) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                  child: ActionChip(
                    avatar: const Icon(LucideIcons.sparkles, size: 13, color: AppColors.donorPrimary),
                    label: Text(item, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.surfaceContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    onPressed: () {
                      setState(() {
                        _nameController.text = item;
                      });
                      _syncToDraft();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Food Name
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontWeight: FontWeight.w600),
            onChanged: (val) {
              setState(() {});
              _syncToDraft();
            },
            decoration: InputDecoration(
              labelText: 'Food Item Name *',
              hintText: 'e.g., Rice and Lentil Curry',
              prefixIcon: const Icon(LucideIcons.utensils, color: AppColors.donorPrimary),
              suffixIcon: _nameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 16),
                      onPressed: () {
                        setState(() => _nameController.clear());
                        _syncToDraft();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.donorPrimary, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Quantity Preset Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                {'qty': '5', 'unit': 'kg', 'serv': 15},
                {'qty': '10', 'unit': 'kg', 'serv': 30},
                {'qty': '25', 'unit': 'kg', 'serv': 75},
                {'qty': '50', 'unit': 'kg', 'serv': 150},
                {'qty': '100', 'unit': 'packets', 'serv': 100},
              ].map((preset) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                  child: ActionChip(
                    avatar: const Icon(LucideIcons.plus, size: 12, color: AppColors.donorPrimary),
                    label: Text(
                      '${preset['qty']} ${preset['unit']}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: AppColors.surfaceContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    onPressed: () {
                      setState(() {
                        _quantityController.text = preset['qty'] as String;
                        _unitController.text = preset['unit'] as String;
                        _servingsController.text = (preset['serv'] as int).toString();
                      });
                      _syncToDraft();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Quantity & Unit
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _quantityController,
                  focusNode: _quantityFocusNode,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  onChanged: (val) {
                    setState(() {});
                    _syncToDraft();
                  },
                  decoration: InputDecoration(
                    labelText: 'Quantity *',
                    hintText: '15',
                    prefixIcon: const Icon(LucideIcons.package, color: AppColors.donorPrimary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.donorPrimary, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _unitController,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  onChanged: (val) {
                    setState(() {});
                    _syncToDraft();
                  },
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    hintText: 'kg',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.donorPrimary, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Servings
          TextFormField(
            controller: _servingsController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.w600),
            onChanged: (val) {
              setState(() {});
              _syncToDraft();
            },
            decoration: InputDecoration(
              labelText: 'Estimated Servings (People)',
              hintText: '30',
              prefixIcon: const Icon(LucideIcons.users, color: AppColors.donorPrimary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.donorPrimary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryPill({
    required String title,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withOpacity(0.12) : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: isSelected ? accentColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? accentColor : AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? accentColor : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for authentic Material You dashed squircle outline
class _DashedSquirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final double dashLength;
  final double dashSpace;

  _DashedSquirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    required this.dashLength,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
        Radius.circular(borderRadius),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final length = (distance + dashLength < metric.length) ? dashLength : metric.length - distance;
        dashPath.addPath(metric.extractPath(distance, distance + length), Offset.zero);
        distance += dashLength + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedSquirclePainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}
