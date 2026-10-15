import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/location_service.dart';
import '../../core/services/communication_service.dart';
import '../../core/repositories/donations_repository.dart';
import '../../core/repositories/rider_jobs_repository.dart';
import '../../core/providers/app_providers.dart';

enum DeliveryState {
  goingToPickup,
  atPickup,
  inTransit,
  atDropoff,
  delivered
}

class ActiveDeliveryScreen extends StatefulWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  DeliveryState _currentState = DeliveryState.goingToPickup;
  final TextEditingController _otpController = TextEditingController();
  final MapController _mapController = MapController();
  StreamSubscription<LatLng>? _locationSubscription;

  // Targets
  static const _pickupLatLng = LatLng(19.0760, 72.8777);
  static const _dropoffLatLng = LatLng(19.0596, 72.8295);

  // Dynamic live Rider location
  LatLng _riderLatLng = LocationService.defaultLocation;
  bool _isGpsActive = false;

  @override
  void initState() {
    super.initState();
    _startLiveTracking();
  }

  Future<void> _startLiveTracking() async {
    final current = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _riderLatLng = current;
        _isGpsActive = true;
      });
      _mapController.move(current, 14.0);
    }

    _locationSubscription = LocationService.getPositionStream().listen((pos) {
      if (mounted) {
        setState(() {
          _riderLatLng = pos;
        });
      }
    });
  }

  void _progressState() {
    switch (_currentState) {
      case DeliveryState.goingToPickup:
        setState(() => _currentState = DeliveryState.atPickup);
        _showSlidingOtpDrawer('Enter 4-Digit Donor Pickup OTP', isPickup: true, onSuccess: () {
          setState(() => _currentState = DeliveryState.inTransit);
          DonationsRepository().updateStatus('d1', DonationStatus.inTransit, riderId: 'R-201');
          RiderJobsRepository().updateJobStatus('j1', 'in_transit', riderId: 'R-201');
        });
        break;
      case DeliveryState.atPickup:
        _showSlidingOtpDrawer('Enter 4-Digit Donor Pickup OTP', isPickup: true, onSuccess: () {
          setState(() => _currentState = DeliveryState.inTransit);
          DonationsRepository().updateStatus('d1', DonationStatus.inTransit, riderId: 'R-201');
          RiderJobsRepository().updateJobStatus('j1', 'in_transit', riderId: 'R-201');
        });
        break;
      case DeliveryState.inTransit:
        setState(() => _currentState = DeliveryState.atDropoff);
        _showSlidingOtpDrawer('Enter 4-Digit Shelter Dropoff OTP', isPickup: false, onSuccess: () {
          setState(() => _currentState = DeliveryState.delivered);
          DonationsRepository().updateStatus('d1', DonationStatus.delivered, riderId: 'R-201');
          RiderJobsRepository().updateJobStatus('j1', 'delivered', riderId: 'R-201');
          _showCelebrationSheet();
        });
        break;
      case DeliveryState.atDropoff:
        _showSlidingOtpDrawer('Enter 4-Digit Shelter Dropoff OTP', isPickup: false, onSuccess: () {
          setState(() => _currentState = DeliveryState.delivered);
          DonationsRepository().updateStatus('d1', DonationStatus.delivered, riderId: 'R-201');
          RiderJobsRepository().updateJobStatus('j1', 'delivered', riderId: 'R-201');
          _showCelebrationSheet();
        });
        break;
      case DeliveryState.delivered:
        _showCelebrationSheet();
        break;
    }
  }

  /// 🎬 Screen 4: Sliding 2-Step OTP Handshake Drawer
  void _showSlidingOtpDrawer(String title, {required bool isPickup, required VoidCallback onSuccess}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OtpDrawerContent(
        title: title,
        isPickup: isPickup,
        initialOtp: '1234',
        onVerified: () {
          Navigator.pop(ctx);
          onSuccess();
        },
      ),
    );
  }

  /// 🎬 Screen 5: Celebratory Delivery Complete Rosette Bottom Sheet
  void _showCelebrationSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CelebrationSheetContent(),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetLatLng = _currentState == DeliveryState.goingToPickup || _currentState == DeliveryState.atPickup
        ? _pickupLatLng
        : _dropoffLatLng;

    return Scaffold(
      backgroundColor: AppColors.canvasCeramic,
      body: Stack(
        children: [
          // Real flutter_map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _riderLatLng,
              initialZoom: 13.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.foodbridge',
              ),
              MarkerLayer(
                markers: [
                  // Rider marker
                  Marker(
                    point: _riderLatLng,
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.riderPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.riderPrimary.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.bike, color: Colors.white, size: 20),
                    ),
                  ),
                  // Pickup marker
                  Marker(
                    point: _pickupLatLng,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.donorPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.donorPrimary.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.utensils, color: Colors.white, size: 18),
                    ),
                  ),
                  // Dropoff marker
                  Marker(
                    point: _dropoffLatLng,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.ngoPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ngoPrimary.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.building, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_riderLatLng, targetLatLng],
                    strokeWidth: 5,
                    color: AppColors.riderPrimary.withOpacity(0.8),
                    isDotted: true,
                  ),
                ],
              ),
            ],
          ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/role-selection');
                        }
                      },
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.ngoPrimary,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ngoPrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.zap, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'LIVE RESCUE NAVIGATION',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sliding Navigation Drawer Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), // 28dp squircle
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusIndicator(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentState == DeliveryState.goingToPickup || _currentState == DeliveryState.atPickup
                                ? 'Pickup Location'
                                : 'Drop-off Destination',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currentState == DeliveryState.goingToPickup || _currentState == DeliveryState.atPickup
                                ? 'Spice Garden Hotel & Kitchen'
                                : 'Helping Hands Shelter NGO',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.phone, color: AppColors.riderPrimary),
                            style: IconButton.styleFrom(backgroundColor: AppColors.riderContainer.withOpacity(0.5)),
                            tooltip: 'Call Location',
                            onPressed: () => CommunicationService.makePhoneCall('+919876543210'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(LucideIcons.messageSquare, color: AppColors.riderPrimary),
                            style: IconButton.styleFrom(backgroundColor: AppColors.riderContainer.withOpacity(0.5)),
                            tooltip: 'Send SMS',
                            onPressed: () => CommunicationService.sendSms(
                              '+919876543210',
                              body: 'Hi, FoodBridge rider here for the surplus food rescue.',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentState == DeliveryState.atPickup || _currentState == DeliveryState.atDropoff
                            ? AppColors.riderPrimary
                            : AppColors.donorPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      onPressed: _progressState,
                      child: Text(
                        _getButtonText(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // GPS Recenter Button
          Positioned(
            right: 16,
            bottom: 240,
            child: FloatingActionButton.small(
              backgroundColor: AppColors.surface,
              foregroundColor: _isGpsActive ? AppColors.accent : AppColors.riderPrimary,
              tooltip: 'Center GPS Location',
              onPressed: () {
                _mapController.move(_riderLatLng, 15.0);
              },
              child: Icon(_isGpsActive ? LucideIcons.crosshair : LucideIcons.locateFixed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Row(
      children: [
        _buildDot(DeliveryState.goingToPickup),
        _buildLine(DeliveryState.atPickup),
        _buildDot(DeliveryState.atPickup),
        _buildLine(DeliveryState.inTransit),
        _buildDot(DeliveryState.inTransit),
        _buildLine(DeliveryState.atDropoff),
        _buildDot(DeliveryState.atDropoff),
      ],
    );
  }

  Widget _buildDot(DeliveryState state) {
    bool isActive = _currentState.index >= state.index;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: isActive ? AppColors.riderPrimary : AppColors.surfaceContainerHigh,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.riderPrimary : AppColors.border,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildLine(DeliveryState state) {
    bool isActive = _currentState.index >= state.index;
    return Expanded(
      child: Container(
        height: 3,
        color: isActive ? AppColors.riderPrimary : AppColors.surfaceContainerHigh,
      ),
    );
  }

  String _getButtonText() {
    switch (_currentState) {
      case DeliveryState.goingToPickup:
        return 'Arrived at Pickup';
      case DeliveryState.atPickup:
        return 'Enter Donor Pickup OTP (1234)';
      case DeliveryState.inTransit:
        return 'Arrived at Shelter Drop-off';
      case DeliveryState.atDropoff:
        return 'Enter Shelter Dropoff OTP (1234)';
      case DeliveryState.delivered:
        return 'View Mission Impact';
    }
  }
}

// ────────── 🎬 Scene 4: 2-Step OTP Handshake Sliding Drawer (Animated) ──────────
class _OtpDrawerContent extends StatefulWidget {
  final String title;
  final bool isPickup;
  final String initialOtp;
  final VoidCallback onVerified;

  const _OtpDrawerContent({
    required this.title,
    required this.isPickup,
    required this.initialOtp,
    required this.onVerified,
  });

  @override
  State<_OtpDrawerContent> createState() => _OtpDrawerContentState();
}

class _OtpDrawerContentState extends State<_OtpDrawerContent> with TickerProviderStateMixin {
  late final List<AnimationController> _digitControllers;
  late final List<Animation<double>> _scaleAnimations;
  final List<String> _enteredDigits = [];
  bool _isVerifiedAnimation = false;

  @override
  void initState() {
    super.initState();
    // 4 Elastic Scale Animation Controllers for [ 1 ] [ 2 ] [ 3 ] [ 4 ]
    _digitControllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 380),
      ),
    );

    _scaleAnimations = _digitControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.elasticOut,
        ),
      );
    }).toList();
  }

  void _typeDigit(String digit) {
    if (_enteredDigits.length < 4) {
      final index = _enteredDigits.length;
      setState(() {
        _enteredDigits.add(digit);
      });
      _digitControllers[index].forward(from: 0.0);
    }
  }

  void _backspace() {
    if (_enteredDigits.isNotEmpty) {
      final index = _enteredDigits.length - 1;
      _digitControllers[index].reverse().then((_) {
        if (mounted) {
          setState(() {
            _enteredDigits.removeLast();
          });
        }
      });
    }
  }

  void _clearAll() {
    for (var c in _digitControllers) {
      c.reset();
    }
    setState(() {
      _enteredDigits.clear();
    });
  }

  void _handleVerify() {
    if (_enteredDigits.length < 4) return;
    setState(() => _isVerifiedAnimation = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        widget.onVerified();
      }
    });
  }

  @override
  void dispose() {
    for (var c in _digitControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _enteredDigits.length == 4;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)), // 28dp squircle
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.riderOnContainer,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isPickup
                    ? '2-Step OTP Handshake — Step 1 of 2: Donor Verification'
                    : '2-Step OTP Handshake — Step 2 of 2: Shelter Handshake',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),

              // Progress Slider Track
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widget.isPickup ? 0.5 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.riderPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 4 Large Squircle Digit Boxes: [ 1 ] [ 2 ] [ 3 ] [ 4 ] with Elastic Pop Animation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final hasDigit = index < _enteredDigits.length;
                  final isCurrentActive = index == _enteredDigits.length;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: 66,
                    height: 74,
                    decoration: BoxDecoration(
                      color: hasDigit ? AppColors.riderOtpBox : Colors.white,
                      borderRadius: BorderRadius.circular(18), // 18dp squircle
                      border: Border.all(
                        color: hasDigit
                            ? AppColors.riderPrimary
                            : isCurrentActive
                                ? AppColors.riderPrimary.withOpacity(0.6)
                                : AppColors.surfaceContainerHigh,
                        width: hasDigit ? 2.0 : (isCurrentActive ? 1.8 : 1.2),
                      ),
                      boxShadow: hasDigit
                          ? [
                              BoxShadow(
                                color: AppColors.riderPrimary.withOpacity(0.22),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : isCurrentActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.riderPrimary.withOpacity(0.12),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                    ),
                    child: Center(
                      child: hasDigit
                          ? ScaleTransition(
                              scale: _scaleAnimations[index],
                              child: Text(
                                _enteredDigits[index],
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.riderOnContainer, // #173752
                                ),
                              ),
                            )
                          : (isCurrentActive
                              ? Container(
                                  width: 12,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: AppColors.riderPrimary.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                )
                              : const SizedBox.shrink()),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 18),

              // Interactive Tactile Keypad
              _buildKeypad(),

              const SizedBox(height: 20),

              // Primary Action Pill Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isVerifiedAnimation
                        ? const Color(0xFF0D652D) // Green on success
                        : (isComplete ? AppColors.riderPrimary : AppColors.surfaceContainerHigh),
                    foregroundColor: Colors.white,
                    elevation: isComplete ? 2 : 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  onPressed: isComplete ? _handleVerify : null,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isVerifiedAnimation
                        ? const Row(
                            key: ValueKey('verified'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'OTP Verified ✓',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : Text(
                            key: const ValueKey('verify_btn'),
                            widget.isPickup ? 'Verify & In Transit' : 'Verify & Complete Delivery',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeyRow(['1', '2', '3']),
        const SizedBox(height: 8),
        _buildKeyRow(['4', '5', '6']),
        const SizedBox(height: 8),
        _buildKeyRow(['7', '8', '9']),
        const SizedBox(height: 8),
        _buildKeyRow(['C', '0', '⌫']),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) {
        final isAction = key == 'C' || key == '⌫';
        return Expanded(
          child: Container(
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: Material(
              color: isAction ? AppColors.surfaceContainerHigh.withOpacity(0.5) : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  if (key == 'C') {
                    _clearAll();
                  } else if (key == '⌫') {
                    _backspace();
                  } else {
                    _typeDigit(key);
                  }
                },
                child: Center(
                  child: key == '⌫'
                      ? const Icon(LucideIcons.delete, size: 18, color: AppColors.riderOnContainer)
                      : Text(
                          key,
                          style: TextStyle(
                            fontSize: isAction ? 14 : 20,
                            fontWeight: FontWeight.bold,
                            color: isAction ? AppColors.textSecondary : AppColors.riderOnContainer,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ────────── 🎬 Scene 5: Celebratory Delivery Complete Rosette Modal (2x2 Grid) ──────────
class _CelebrationSheetContent extends StatefulWidget {
  const _CelebrationSheetContent();

  @override
  State<_CelebrationSheetContent> createState() => _CelebrationSheetContentState();
}

class _CelebrationSheetContentState extends State<_CelebrationSheetContent> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.elasticOut,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)), // 28dp squircle
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grab Handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 22),

            // Hero Rosette Badge (12-Point Pastel Mint #D6F5E3 with Green Checkmark #0D652D)
            ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(90, 90),
                      painter: _ScallopedRosettePainter(color: const Color(0xFFD6F5E3)),
                    ),
                    const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF0D652D), // Green checkmark
                      size: 44,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Impact Typography
            const Text(
              'Delivery Complete!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '50 Meals Rescued',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E6B4F), // Deep Sage Green
              ),
            ),

            const SizedBox(height: 24),

            // 🎬 2x2 Grid of 4 Metric Squircle Cards (Matching next part.mp4)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Row 1: Food Saved & CO2 Prevented
                  Row(
                    children: [
                      // Card 1: 45 kg / Food Saved
                      Expanded(
                        child: _buildMetricSquircleCard(
                          value: '45 kg',
                          label: 'Food Saved',
                          icon: LucideIcons.utensils,
                          accentColor: const Color(0xFF1E4620), // Forest green
                          containerColor: const Color(0xFFE8F5E9), // Mint tonal container
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Card 2: 18 kg / CO2 Prevented
                      Expanded(
                        child: _buildMetricSquircleCard(
                          value: '18 kg',
                          label: 'CO2 Prevented',
                          icon: LucideIcons.leaf,
                          accentColor: const Color(0xFF0D652D), // Emerald
                          containerColor: const Color(0xFFE6F4EA), // Emerald tonal container
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 2: Relief Impact & Karma Points
                  Row(
                    children: [
                      // Card 3: +15 kg / Relief Impact ⓘ
                      Expanded(
                        child: _buildMetricSquircleCard(
                          value: '+15 kg',
                          label: 'Relief Impact ⓘ',
                          icon: LucideIcons.heartHandshake,
                          accentColor: const Color(0xFFB06000), // Amber
                          containerColor: const Color(0xFFFEF7E0), // Peach/Amber tonal container
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Card 4: +150 / Karma Points
                      Expanded(
                        child: _buildMetricSquircleCard(
                          value: '+150',
                          label: 'Karma Points',
                          icon: LucideIcons.sparkles,
                          accentColor: const Color(0xFF6200EE), // Violet
                          containerColor: const Color(0xFFF3E8FD), // Purple tonal container
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Return to Dispatch Hub Pill CTA Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6B4F), // Deep sage green
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/role-selection');
                },
                child: const Text(
                  'Return to Dispatch Hub',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSquircleCard({
    required String value,
    required String label,
    required IconData icon,
    required Color accentColor,
    required Color containerColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(20), // 20dp squircle
        border: Border.all(
          color: accentColor.withOpacity(0.12),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the 12-lobed scalloped celebratory mint rosette badge
class _ScallopedRosettePainter extends CustomPainter {
  final Color color;
  _ScallopedRosettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const count = 12;

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi) / count;
      final lobeCenter = Offset(
        center.dx + (radius * 0.68) * math.cos(angle),
        center.dy + (radius * 0.68) * math.sin(angle),
      );
      canvas.drawCircle(lobeCenter, radius * 0.32, paint);
    }
    canvas.drawCircle(center, radius * 0.72, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

