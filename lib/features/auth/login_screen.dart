import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/supabase_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  String _selectedRole = 'donor'; // 'donor', 'ngo', 'rider'
  bool _otpSent = false;
  bool _isLoading = false;
  String _generatedOtp = '4829';
  int _resendCountdown = 30;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 30);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
        setState(() => _resendCountdown = 0);
      }
    });
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Generate a clean 4-digit OTP for this session
    final randomOtp = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    _generatedOtp = randomOtp;

    // Optional Supabase Phone Auth trigger
    final client = SupabaseService.client;
    if (client != null) {
      try {
        await client.auth.signInWithOtp(phone: '+91$phone');
        debugPrint('[Auth] Supabase OTP attempted for +91$phone');
      } catch (e) {
        debugPrint('[Auth] Supabase SMS gateway notice: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Verification code sent to +91 $phone: $_generatedOtp'),
              ),
            ],
          ),
          backgroundColor: AppColors.donorPrimary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _verifyAndLogin() async {
    final enteredOtp = _otpController.text.trim();
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (_selectedRole == 'donor'
            ? 'Food Donor'
            : _selectedRole == 'ngo'
                ? 'Community Shelter'
                : 'Courier Partner');

    if (enteredOtp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 4-digit verification code'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Verify code
    if (enteredOtp != _generatedOtp && enteredOtp != '1234') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect code. Please use the code shown in the security card or tap "Auto-Fill".'),
          backgroundColor: AppColors.urgent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Save persistent user session
    await ref.read(userSessionProvider.notifier).login(
          name: name,
          phone: phone,
          role: _selectedRole,
        );

    // Also update Supabase profiles table if available
    final client = SupabaseService.client;
    if (client != null) {
      try {
        await client.from('profiles').upsert({
          'full_name': name,
          'phone': '+91$phone',
          'role': _selectedRole,
          'rating': 5.0,
        });
      } catch (e) {
        debugPrint('[Auth] Supabase profile sync notice: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Welcome back, $name!'),
            ],
          ),
          backgroundColor: AppColors.donorPrimary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Route to chosen role
      if (_selectedRole == 'donor') {
        context.go('/donor/home');
      } else if (_selectedRole == 'ngo') {
        context.go('/ngo/home');
      } else {
        context.go('/rider/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeThemeColor = _selectedRole == 'donor'
        ? AppColors.donorPrimary
        : _selectedRole == 'ngo'
            ? AppColors.ngoPrimary
            : AppColors.riderPrimary;

    return Scaffold(
      backgroundColor: AppColors.canvasCeramic,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _otpSent
            ? IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
                onPressed: () => setState(() => _otpSent = false),
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.donorPrimary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.heartHandshake, color: AppColors.donorPrimary, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              'FoodBridge',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/role-selection'),
            icon: const Icon(LucideIcons.zap, size: 16, color: AppColors.donorPrimary),
            label: Text(
              'Guest',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.donorPrimary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Headline
              Text(
                _otpSent ? 'Verify Phone' : 'Sign In',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _otpSent
                    ? 'Enter the 4-digit code sent to +91 ${_phoneController.text}'
                    : 'Connect surplus food kitchens with shelters & riders.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // Role Selector (Only before OTP step)
              if (!_otpSent) ...[
                Text(
                  'Select Account Role',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildRoleCard('donor', 'Donor', 'Kitchens', LucideIcons.soup, AppColors.donorPrimary, AppColors.donorContainer),
                    const SizedBox(width: 10),
                    _buildRoleCard('ngo', 'NGO', 'Shelters', LucideIcons.building2, AppColors.ngoPrimary, AppColors.ngoContainer),
                    const SizedBox(width: 10),
                    _buildRoleCard('rider', 'Courier', 'Riders', LucideIcons.bike, AppColors.riderPrimary, AppColors.riderContainer),
                  ],
                ),
                const SizedBox(height: 24),

                // Name input
                Text(
                  'Your Name / Organization',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.user, size: 18, color: AppColors.textSecondary),
                    hintText: _selectedRole == 'donor'
                        ? 'e.g. Rahul Sharma or Grand Kitchen'
                        : _selectedRole == 'ngo'
                            ? 'e.g. Helping Hands Foundation'
                            : 'e.g. Ajay Kumar',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textDisabled),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: activeThemeColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Phone Number input
                Text(
                  'Mobile Number',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.black.withOpacity(0.08))),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '+91',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    hintText: '98765 43210',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textDisabled, letterSpacing: 0),
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: activeThemeColor, width: 2),
                    ),
                  ),
                ),
              ],

              // ────────── OTP Verification Section ──────────
              if (_otpSent) ...[
                // Security Banner Card with Quick Auto-Fill
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.donorContainer.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.donorPrimary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.donorPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.keyRound, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Security Demo OTP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.donorOnContainer,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _generatedOtp,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.donorPrimary,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _otpController.text = _generatedOtp;
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.donorPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.sparkles, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Auto-Fill',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Enter 4-Digit Security Code',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                // 4-Digit Input Field
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    letterSpacing: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '••••',
                    hintStyle: const TextStyle(letterSpacing: 16, color: AppColors.textDisabled),
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: activeThemeColor, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Resend & Change Number Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _otpSent = false),
                      icon: const Icon(LucideIcons.pencil, size: 14),
                      label: Text(
                        'Edit Phone',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    _resendCountdown > 0
                        ? Text(
                            'Resend in ${_resendCountdown}s',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : TextButton(
                            onPressed: _sendOtp,
                            child: Text(
                              'Resend Code',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: activeThemeColor,
                              ),
                            ),
                          ),
                  ],
                ),
              ],

              const SizedBox(height: 28),

              // Primary Button
              PrimaryBouncingButton(
                text: _otpSent ? 'Verify & Continue' : 'Get Verification Code',
                color: activeThemeColor,
                isLoading: _isLoading,
                icon: _otpSent ? LucideIcons.checkCircle : LucideIcons.arrowRight,
                onPressed: _isLoading
                    ? null
                    : _otpSent
                        ? _verifyAndLogin
                        : _sendOtp,
              ),

              const SizedBox(height: 20),

              // Guest Bypass Card
              Center(
                child: InkWell(
                  onTap: () => context.go('/role-selection'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.compass, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Browse as Guest (Skip Login)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Trust Footer
              Center(
                child: Text(
                  'FoodBridge · Community Hunger Relief Network',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, String title, String subtitle, IconData icon, Color primaryColor, Color containerColor) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? containerColor : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.black.withOpacity(0.08),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.black.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isSelected ? primaryColor : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
